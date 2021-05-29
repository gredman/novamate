public extension NovaGrammar {
    init(extension: VSCodeExtension, grammar: VSCodeGrammar) {
        Console.debug("converting top level patterns")
        let scopes = [NovaGrammar.Scope](
            patterns: grammar.patterns,
            scopeName: grammar.scopeName)

        Console.debug("converting repository")
        let collections = [NovaGrammar.Collections.Collection](repository: grammar.repository, scopeName: grammar.scopeName)

        let language = `extension`.contributes.languages.first(where: { $0.id == grammar.name })
        let extensions = language?.extensions ?? []

        self.init(
            name: grammar.name,
            meta: Meta(
                name: grammar.name,
                preferredFileExtension: extensions.first),
            detectors: Detectors(extension: extensions.map {
                Detectors.Extension(priority: 1.0, value: $0)
            }),
            brackets: Pairs(pair: []),
            surroundingPairs: Pairs(pair: []),
            scopes: Scopes(scopes: scopes),
            collections: Collections(collection: collections))
    }
}
