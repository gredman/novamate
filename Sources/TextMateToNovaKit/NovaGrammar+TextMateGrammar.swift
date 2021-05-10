import Foundation

public extension NovaGrammar {
    init(textMateGrammar: TextMateGrammar) {
        let scopes = textMateGrammar.patterns
            .compactMap(NovaGrammar.Scope.init(rule:))

        let collections = textMateGrammar.repository.compactMap { keyValue -> NovaGrammar.Collections.Collection? in
            guard let scope = NovaGrammar.Scope(rule: keyValue.value) else { return nil }
            return NovaGrammar.Collections.Collection(name: keyValue.key, scope: scope)
        }
        self.init(
            name: textMateGrammar.name,
            meta: Meta(
                name: textMateGrammar.name,
                preferredFileExtension: textMateGrammar.fileTypes.first),
            detectors: textMateGrammar.fileTypes.map {
                Detector(
                    extension: Detector.Extension(
                        priority: 1.0,
                        value: $0))
            },
            scopes: Scopes(scopes: scopes),
            collections: Collections(collection: collections))
    }
}

private extension NovaGrammar.Scope {
    init?(rule: TextMateGrammar.Rule) {
        Console.debug("converting \(rule)")

        let name = rule.name ?? UUID().uuidString
        if let match = rule.match, rule.begin == nil, rule.end == nil, rule.include == nil {
            let expression = Pattern(expression: match, captures: rule.captures)
            self = .match(.init(name: name, expression: expression))
        } else if let begin = rule.begin, let end = rule.end, rule.match == nil, rule.include == nil {
            let startsWith = Pattern(expression: begin, captures: rule.beginCaptures)
            let endsWith = Pattern(expression: end, captures: rule.endCaptures)
            let subscopes = (rule.patterns ?? []).compactMap(NovaGrammar.Scope.init(rule:))
            self = .startEnd(.init(name: name, startsWith: startsWith, endsWith: endsWith, subscopes: NovaGrammar.Scopes(scopes: subscopes)))
        } else if let include = rule.include, rule.name == nil, rule.match == nil, rule.end == nil {
            self = .include(.init(collection: include))
        } else {
            Console.error("unhandled rule \(rule)")
            return nil
        }
    }
}

private extension NovaGrammar.Scope.Pattern {
    init(expression: String, captures: [Int: TextMateGrammar.Rule.Capture]?) {
        self.expression = expression
        self.captures = captures?.map { keyValue in
            Capture(number: keyValue.key, name: keyValue.value.name)
        }
    }
}
