public extension NovaGrammar {
    init(extension: VSCodeExtension, language: VSCodeExtension.Contributes.Language, grammar: VSCodeGrammar, replacements: [ScopeReplacement]) {
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

        self.init(
            name: grammar.name,
            meta: Meta(
                name: grammar.name,
                preferredFileExtension: language.extensions.first,
                _disclaimer: disclaimer(extension: `extension`, language: language)),
            detectors: Detectors(extension: language.extensions.map {
                Detectors.Extension(priority: 1.0, value: $0)
            }),
            brackets: Pairs(pair: []),
            surroundingPairs: Pairs(pair: []),
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
