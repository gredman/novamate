public struct NovaGrammarBuilder {
    let sourceGrammar: SourceGrammar
    let replacements: [ScopeReplacement]

    public init(sourceGrammar: SourceGrammar, replacements: [ScopeReplacement]) {
        self.sourceGrammar = sourceGrammar
        self.replacements = replacements
    }

    var prefix: ScopeName {
        sourceGrammar.scopeName
    }

    func scopes() -> [NovaGrammar.Scope] {
        sourceGrammar.patterns.compactMap(self.scope(rule:))
    }

    func scope(rule: SourceGrammar.Rule) -> NovaGrammar.Scope? {
        Console.debug("converting", rule)

        let converted: NovaGrammar.Scope?

        if let match = rule.match, rule.begin == nil, rule.end == nil, rule.include == nil {
            let name = rule.name?.applying(replacements: replacements)
            let match = self.match(
                name: name,
                expression: match,
                captures: rule.captures)
            converted = .match(match)
        } else if let begin = rule.begin, let end = rule.end, rule.match == nil, rule.include == nil {
            let name = rule.name.map { $0.prepending(prefix) }?.applying(replacements: replacements)
            let startsWith = pattern(expression: begin, captures: rule.beginCaptures)
            let endsWith = pattern(expression: end, captures: rule.endCaptures)
            let subscopes = (rule.patterns ?? []).compactMap {
                self.scope(rule: $0)
            }
            converted = .startEnd(.init(name: name, startsWith: startsWith, endsWith: endsWith, subscopes: NovaGrammar.Scopes(scopes: subscopes)))
        } else if let include = rule.include, rule.match == nil, rule.end == nil {
            converted = .include(.init(collection: include))
        } else {
            Console.error("unhandled rule \(rule)")
            converted = nil
        }

        Console.debug("converted", String(describing: converted))
        return converted
    }

    func collections() -> [NovaGrammar.Collections.Collection] {
        sourceGrammar.repository
            .sorted(by: \.key.rawValue)
            .map { keyValue -> NovaGrammar.Collections.Collection in
                let rules = keyValue.value.expandedPatterns(replacements: replacements)
                let scopes = rules.compactMap(self.scope(rule:))
                return NovaGrammar.Collections.Collection(name: keyValue.key, scopes: scopes)
            }
    }

    func pattern(expression: String, captures: [Int: SourceGrammar.Rule.Capture]?) -> NovaGrammar.Scope.Pattern {
        let capture = captures?.sorted(by: \.key).map { keyValue -> NovaGrammar.Scope.Pattern.Capture in
            let name = keyValue.value.name.map { scopeName -> ScopeName in
                scopeName.applying(replacements: replacements).prepending(self.prefix)
            }
            return NovaGrammar.Scope.Pattern.Capture(number: keyValue.key, name: name)
        }
        return NovaGrammar.Scope.Pattern(expression: expression, capture: capture)
    }

    func match(name: ScopeName?, expression: String, captures: [Int: SourceGrammar.Rule.Capture]?) -> NovaGrammar.Scope.Match {
        let name = name.map { $0.prepending(prefix) }
        let capture = captures?.sorted(by: \.key).map { keyValue -> NovaGrammar.Scope.Match.Capture in
            if keyValue.value.patterns?.isEmpty == false {
                Console.error("nested patterns discarded", keyValue.value)
            }
            let name = keyValue.value.name.map { scopeName -> ScopeName in
                scopeName.applying(replacements: replacements).prepending(self.prefix)
            }
            return NovaGrammar.Scope.Match.Capture(number: keyValue.key, name: name)
        }
        return NovaGrammar.Scope.Match(name: name, expression: expression, capture: capture)
    }
}

private extension SourceGrammar.Rule {
    func expandedPatterns(replacements: [ScopeReplacement]) -> [SourceGrammar.Rule] {
        guard match == nil, begin == nil, end == nil, include == nil else {
            return [self]
        }

        let renamedPatterns = (patterns ?? []).enumerated().map { (n, p) -> SourceGrammar.Rule in
            var renamed = p
            renamed.name = p.name ?? name.map { ScopeName(rawValue: "\($0).\(n)") }
            renamed.name = renamed.name?.applying(replacements: replacements)
            return renamed
        }
        return renamedPatterns.flatMap { $0.expandedPatterns(replacements: replacements) }
    }
}

private extension ScopeName {
    private var groups: [Substring] {
        rawValue.split(separator: ".")
    }

    func applying(replacements: [ScopeReplacement]) -> ScopeName {
        let rawValue = replacements.reduce(self.rawValue) { result, replacement in
            result.replacingOccurrences(of: replacement.from, with: replacement.to)
        }
        return ScopeName(rawValue: rawValue)
    }

    func prepending(_ prefix: ScopeName) -> ScopeName {
        ScopeName(rawValue: prefix.rawValue + "." + rawValue)
    }
}
