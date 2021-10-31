public extension NovaGrammarBuilder {
    func fromVSCode(
        configuration: VSCodeLanguageConfiguration?,
        extension: VSCodeExtension,
        language: VSCodeExtension.Contributes.Language
    ) -> NovaGrammar {
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

        let brackets = (configuration?.brackets ?? [])
            .map {
                NovaGrammar.Pairs.Pair(open: $0.first, close: $0.last)
            }

        let surroundingPairs = (configuration?.surroundingPairs ?? [])
            .map {
                NovaGrammar.Pairs.Pair(open: $0.first, close: $0.last)
            }

        let comments = configuration.map(\.comments).map {
            NovaGrammar.Comments(
                single: $0.lineComment.map(NovaGrammar.Comments.Expression.init(expression:)),
                multiline: $0.blockComment.map {
                    NovaGrammar.Comments.Multiline(
                        startsWith: NovaGrammar.Comments.Expression(expression: $0.first),
                        endsWith: NovaGrammar.Comments.Expression(expression: $0.last))
                })
        }

        let extensionDetectors = language.extensions.map {
            $0.map {
                NovaGrammar.Detectors.Extension(priority: 1.0, value: $0)
            }
        }

        return NovaGrammar(
            name: sourceGrammar.name,
            meta: NovaGrammar.Meta(
                name: sourceGrammar.name,
                preferredFileExtension: language.extensions?.first,
                _disclaimer: disclaimer(extension: `extension`, language: language)),
            detectors: NovaGrammar.Detectors(extension: extensionDetectors),
            comments: comments,
            brackets: NovaGrammar.Pairs(pair: brackets),
            surroundingPairs: NovaGrammar.Pairs(pair: surroundingPairs),
            scopes: NovaGrammar.Scopes(scopes: scopes),
            collections: NovaGrammar.Collections(collection: collections))
    }
}

private func disclaimer(
    extension: VSCodeExtension,
    language: VSCodeExtension.Contributes.Language
) -> String {
        "Converted from grammar `\(language.id)` in \(`extension`.repository.url)"
}
