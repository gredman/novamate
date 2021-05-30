public extension NovaGrammar {
    init(
        configuration: VSCodeLanguageConfiguration?,
        extension: VSCodeExtension,
        language: VSCodeExtension.Contributes.Language,
        grammar: VSCodeGrammar,
        replacements: [ScopeReplacement]
    ) {
        Console.debug("converting top level patterns")
        let scopes = [NovaGrammar.Scope](
            patterns: grammar.patterns,
            scopeName: grammar.scopeName,
            replacements: replacements)

        Console.debug("converting repository")
        let collections = [NovaGrammar.Collections.Collection](
            repository: grammar.repository,
            scopeName: grammar.scopeName,
            replacements: replacements)

        let brackets = (configuration?.brackets ?? [])
            .map {
                Pairs.Pair(open: $0.first, close: $0.last)
            }

        let surroundingPairs = (configuration?.surroundingPairs ?? [])
            .map {
                Pairs.Pair(open: $0.first, close: $0.last)
            }

        let comments = configuration.map(\.comments).map {
            Comments(
                single: $0.lineComment.map(Comments.Expression.init(expression:)),
                multiline: $0.blockComment.map {
                    Comments.Multiline(
                        startsWith: Comments.Expression(expression: $0.first),
                        endsWith: Comments.Expression(expression: $0.last))
                })
        }

        self.init(
            name: grammar.name,
            meta: Meta(
                name: grammar.name,
                preferredFileExtension: language.extensions.first,
                _disclaimer: disclaimer(extension: `extension`, language: language)),
            detectors: Detectors(extension: language.extensions.map {
                Detectors.Extension(priority: 1.0, value: $0)
            }),
            comments: comments,
            brackets: Pairs(pair: brackets),
            surroundingPairs: Pairs(pair: surroundingPairs),
            scopes: Scopes(scopes: scopes),
            collections: Collections(collection: collections))
    }
}

private func disclaimer(
    extension: VSCodeExtension,
    language: VSCodeExtension.Contributes.Language
) -> String {
        "Converted from \"\(`extension`.repository.url)\", grammar \"\(language.id)\"."
}
