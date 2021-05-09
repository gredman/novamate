public extension NovaGrammar {
    init(textMateGrammar: TextMateGrammar) {
        let scopes = textMateGrammar.patterns
            .map(NovaGrammar.Scopes.init(rule:))
            .reduce(NovaGrammar.Scopes.empty, (+))

        let collections = textMateGrammar.repository.map { keyValue -> NovaGrammar.Collections.Collection in
            let scopes = NovaGrammar.Scopes(rule: keyValue.value)
            return NovaGrammar.Collections.Collection(name: keyValue.key, scope: scopes.scope, include: scopes.include)
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
            scopes: scopes,
            collections: Collections(collection: collections))
    }
}

private extension NovaGrammar.Scopes {
    init(rule: TextMateGrammar.Rule) {
        Console.debug("converting \(rule)")
        let match = rule.match.map {
            NovaGrammar.Scope.Pattern(expression: $0, captures: rule.captures)
        }
        let startsWith = rule.begin.map {
            NovaGrammar.Scope.Pattern(expression: $0, captures: rule.beginCaptures)
        }
        let endsWith = rule.end.map {
            NovaGrammar.Scope.Pattern(expression: $0, captures: rule.endCaptures)
        }
        let subscopes = rule.patterns.map {
            $0.map {
                NovaGrammar.Scopes(rule: $0)
            }
        }?.reduce(NovaGrammar.Scopes.empty, (+))
        let include = rule.include.map {
            NovaGrammar.Include(collection: $0)
        }

        let scope = NovaGrammar.Scope(
            name: rule.name,
            expression: match,
            startsWith: startsWith,
            endsWith: endsWith,
            subscopes: subscopes)

        self.init(
            scope: scope.isEmpty ? nil : [scope],
            include: include.map { [$0] })
    }

    static func +(lhs: Self, rhs: Self) -> NovaGrammar.Scopes {
        let scope = (lhs.scope ?? []) + (rhs.scope ?? [])
        let include = (lhs.include ?? []) + (rhs.include ?? [])
        return NovaGrammar.Scopes(scope: scope, include: include)
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
