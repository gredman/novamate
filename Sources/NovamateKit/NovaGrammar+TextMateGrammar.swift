import Foundation

public extension NovaGrammar {
    init(settings: TextMateBundle.Settings = .init(), textMateGrammar: TextMateGrammar) {
        let brackets = settings.highlightPairs.map { pair in Pairs.Pair(open: pair.0, close: pair.1) }
        let surroundingPairs = settings.smartTypingPairs.map { pair in Pairs.Pair(open: pair.0, close: pair.1) }

        Console.debug("converting top level patterns")
        let scopes = [NovaGrammar.Scope](
            patterns: textMateGrammar.patterns,
            scopeName: textMateGrammar.scopeName)

        Console.debug("converting repository")
        let collections = [NovaGrammar.Collections.Collection](repository: textMateGrammar.repository, scopeName: textMateGrammar.scopeName)

        self.init(
            name: textMateGrammar.name,
            meta: Meta(
                name: textMateGrammar.name,
                preferredFileExtension: textMateGrammar.fileTypes.first),
            detectors: Detectors(extension: textMateGrammar.fileTypes.map {
                Detectors.Extension(priority: 1.0, value: $0)
            }),
            brackets: Pairs(pair: brackets),
            surroundingPairs: Pairs(pair: surroundingPairs),
            scopes: Scopes(scopes: scopes),
            collections: Collections(collection: collections))
    }
}

extension Array where Element == NovaGrammar.Scope {
    init(patterns: [TextMateGrammar.Rule], scopeName: String) {
        self = patterns.compactMap { NovaGrammar.Scope(rule: $0, prefix: scopeName) }
    }
}

extension Array where Element == NovaGrammar.Collections.Collection {
    init(repository: [String: TextMateGrammar.Rule], scopeName: String) {
        self = repository
            .sorted(by: \.key)
            .map { keyValue -> NovaGrammar.Collections.Collection in
                let rules = keyValue.value.expandedPatterns
                let scopes = rules.compactMap { rule -> NovaGrammar.Scope? in
                    NovaGrammar.Scope(rule: rule, prefix: scopeName)
                }
                return NovaGrammar.Collections.Collection(name: keyValue.key, scopes: scopes)
            }
    }
}

private extension TextMateGrammar.Rule {
    var expandedPatterns: [TextMateGrammar.Rule] {
        guard match == nil, begin == nil, end == nil, include == nil else {
            return [self]
        }

        let renamedPatterns = (patterns ?? []).enumerated().map { (n, p) -> TextMateGrammar.Rule in
            var renamed = p
            renamed.name = p.name ?? name.map { "\($0).\(n)" }
            renamed.name = renamed.name?.textMateGroupNamesReplaced
            return renamed
        }
        return renamedPatterns.flatMap(\.expandedPatterns)
    }
}

private extension NovaGrammar.Scope {
    init?(rule: TextMateGrammar.Rule, prefix: String) {
        Console.debug("converting \(rule)")

        if let match = rule.match, rule.begin == nil, rule.end == nil, rule.include == nil {
            let match = Match(name: rule.name?.textMateGroupNamesReplaced, expression: match, captures: rule.captures, prefix: prefix)
            self = .match(match)
        } else if let begin = rule.begin, let end = rule.end, rule.match == nil, rule.include == nil {
            let name = rule.name.map { prefix + "." + $0 }?.textMateGroupNamesReplaced
            let startsWith = Pattern(expression: begin, captures: rule.beginCaptures, prefix: prefix)
            let endsWith = Pattern(expression: end, captures: rule.endCaptures, prefix: prefix)
            let subscopes = (rule.patterns ?? []).compactMap {
                NovaGrammar.Scope(rule: $0, prefix: prefix)
            }
            self = .startEnd(.init(name: name, startsWith: startsWith, endsWith: endsWith, subscopes: NovaGrammar.Scopes(scopes: subscopes)))
        } else if let include = rule.include, rule.match == nil, rule.end == nil {
            self = .include(.init(collection: include))
        } else {
            Console.error("unhandled rule \(rule)")
            return nil
        }
    }
}

private extension NovaGrammar.Scope.Pattern {
    init(expression: String, captures: [Int: TextMateGrammar.Rule.Capture]?, prefix: String) {
        self.expression = expression
        self.capture = captures?.sorted(by: \.key).map { keyValue in
            Capture(number: keyValue.key, name: keyValue.value.name.map { prefix + "." + $0.textMateGroupNamesReplaced })
        }
    }
}

private extension NovaGrammar.Scope.Match {
    init(name: String?, expression: String, captures: [Int: TextMateGrammar.Rule.Capture]?, prefix: String) {
        self.name = name.map { prefix + "." + $0 }
        self.expression = expression
        self.capture = captures?.sorted(by: \.key).map { keyValue in
            Capture(number: keyValue.key, name: keyValue.value.name.map { prefix + "." + $0.textMateGroupNamesReplaced })
        }
    }
}

private extension String {
    private static let replacements: [(String, String)] = [
        ("constant.language", "value"),
        ("constant.numeric", "value.number"),
        ("entity.name.function", "identifier.function"),
        ("entity.name.tag", "tag"),
        ("entity.name.type", "identifier.type"),
        ("storage", "keyword"),
        ("variable.language", "identifier.core"),
        ("variable.parameter", "identifier.argument")
    ]

    private var groups: [Substring] {
        split(separator: ".")
    }

    var textMateGroupNamesReplaced: String {
        Self.replacements.reduce(self) { result, pair in
            result.replacingOccurrences(of: pair.0, with: pair.1)
        }
    }
}
