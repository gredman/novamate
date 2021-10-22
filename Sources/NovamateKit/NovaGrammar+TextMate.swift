import Foundation

public extension NovaGrammar {
    init(settings: TextMateBundle.Settings = .init(), sourceGrammar: SourceGrammar, replacements: [ScopeReplacement]) {
        let brackets = settings.highlightPairs.map { pair in Pairs.Pair(open: pair.0, close: pair.1) }
        let surroundingPairs = settings.smartTypingPairs.map { pair in Pairs.Pair(open: pair.0, close: pair.1) }

        Console.debug("converting top level patterns")
        let scopes = [NovaGrammar.Scope](
            patterns: sourceGrammar.patterns,
            scopeName: sourceGrammar.scopeName,
            replacements: replacements)

        Console.debug("converting repository")
        let collections = [NovaGrammar.Collections.Collection](
            repository: sourceGrammar.repository,
            scopeName: sourceGrammar.scopeName,
            replacements: replacements)

        let extensionDetectors = sourceGrammar.fileTypes.map {
            $0.map {
                Detectors.Extension(priority: 1.0, value: $0)
            }
        }

        self.init(
            name: sourceGrammar.name,
            meta: Meta(
                name: sourceGrammar.name,
                preferredFileExtension: sourceGrammar.fileTypes?.first,
                _disclaimer: nil),
            detectors: Detectors(extension: extensionDetectors),
            comments: nil,    // TODO
            brackets: Pairs(pair: brackets),
            surroundingPairs: Pairs(pair: surroundingPairs),
            scopes: Scopes(scopes: scopes),
            collections: Collections(collection: collections))
    }
}

extension Array where Element == NovaGrammar.Scope {
    init(patterns: [SourceGrammar.Rule], scopeName: String, replacements: [ScopeReplacement]) {
        self = patterns.compactMap { NovaGrammar.Scope(rule: $0, prefix: scopeName, replacements: replacements) }
    }
}

extension Array where Element == NovaGrammar.Collections.Collection {
    init(repository: [String: SourceGrammar.Rule], scopeName: String, replacements: [ScopeReplacement]) {
        self = repository
            .sorted(by: \.key)
            .map { keyValue -> NovaGrammar.Collections.Collection in
                let rules = keyValue.value.expandedPatterns(replacements: replacements)
                let scopes = rules.compactMap { rule -> NovaGrammar.Scope? in
                    NovaGrammar.Scope(rule: rule, prefix: scopeName, replacements: replacements)
                }
                return NovaGrammar.Collections.Collection(name: keyValue.key, scopes: scopes)
            }
    }
}

private extension SourceGrammar.Rule {
    func expandedPatterns(replacements: [ScopeReplacement]) -> [SourceGrammar.Rule] {
        guard match == nil, begin == nil, end == nil, include == nil else {
            return [self]
        }

        let renamedPatterns = (patterns ?? []).enumerated().map { (n, p) -> SourceGrammar.Rule in
            var renamed = p
            renamed.name = p.name ?? name.map { "\($0).\(n)" }
            renamed.name = renamed.name?.applying(replacements: replacements)
            return renamed
        }
        return renamedPatterns.flatMap { $0.expandedPatterns(replacements: replacements) }
    }
}

private extension NovaGrammar.Scope {
    init?(rule: SourceGrammar.Rule, prefix: String, replacements: [ScopeReplacement]) {
        Console.debug("converting", rule)

        if let match = rule.match, rule.begin == nil, rule.end == nil, rule.include == nil {
            let name = rule.name?.applying(replacements: replacements)
            let match = Match(
                name: name,
                expression: match,
                captures: rule.captures,
                prefix: prefix,
                replacements: replacements)
            self = .match(match)
        } else if let begin = rule.begin, let end = rule.end, rule.match == nil, rule.include == nil {
            let name = rule.name.map { prefix + "." + $0 }?.applying(replacements: replacements)
            let startsWith = Pattern(expression: begin, captures: rule.beginCaptures, prefix: prefix, replacements: replacements)
            let endsWith = Pattern(expression: end, captures: rule.endCaptures, prefix: prefix, replacements: replacements)
            let subscopes = (rule.patterns ?? []).compactMap {
                NovaGrammar.Scope(rule: $0, prefix: prefix, replacements: replacements)
            }
            self = .startEnd(.init(name: name, startsWith: startsWith, endsWith: endsWith, subscopes: NovaGrammar.Scopes(scopes: subscopes)))
        } else if let include = rule.include, rule.match == nil, rule.end == nil {
            self = .include(.init(collection: include))
        } else {
            Console.error("unhandled rule \(rule)")
            return nil
        }

        Console.debug("converted", self)
    }
}

private extension NovaGrammar.Scope.Pattern {
    init(expression: String, captures: [Int: SourceGrammar.Rule.Capture]?, prefix: String, replacements: [ScopeReplacement]) {
        let capture = captures?.sorted(by: \.key).map { keyValue in
            Capture(number: keyValue.key, name: keyValue.value.name.map { prefix + "." + $0.applying(replacements: replacements) })
        }
        self.init(expression: expression, capture: capture)
    }
}

private extension NovaGrammar.Scope.Match {
    init(name: String?, expression: String, captures: [Int: SourceGrammar.Rule.Capture]?, prefix: String, replacements: [ScopeReplacement]) {
        let name = name.map { prefix + "." + $0 }
        let capture = captures?.sorted(by: \.key).map { keyValue in
            Capture(number: keyValue.key, name: keyValue.value.name.map { prefix + "." + $0.applying(replacements: replacements) })
        }
        self.init(name: name, expression: expression, capture: capture)
    }
}

private extension String {
    private var groups: [Substring] {
        split(separator: ".")
    }

    func applying(replacements: [ScopeReplacement]) -> String {
        replacements.reduce(self) { result, replacement in
            result.replacingOccurrences(of: replacement.from, with: replacement.to)
        }
    }
}
