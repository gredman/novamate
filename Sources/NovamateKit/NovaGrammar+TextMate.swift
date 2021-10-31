import Foundation

public extension NovaGrammarBuilder {
    func fromTextMate(settings: TextMateBundle.Settings = .init()) -> NovaGrammar {
        let brackets = settings.highlightPairs.map { pair in
            NovaGrammar.Pairs.Pair(open: pair.0, close: pair.1)
        }
        let surroundingPairs = settings.smartTypingPairs.map {
            pair in NovaGrammar.Pairs.Pair(open: pair.0, close: pair.1)
        }

        Console.debug("converting top level patterns")
        let scopes = scopes()

        Console.debug("converting repository")
        let collections = collections()

        let extensionDetectors = sourceGrammar.fileTypes.map {
            $0.map {
                NovaGrammar.Detectors.Extension(priority: 1.0, value: $0)
            }
        }

        return NovaGrammar(
            name: sourceGrammar.name,
            meta: NovaGrammar.Meta(
                name: sourceGrammar.name,
                preferredFileExtension: sourceGrammar.fileTypes?.first,
                _disclaimer: nil),
            detectors: NovaGrammar.Detectors(extension: extensionDetectors),
            comments: nil,    // TODO
            brackets: NovaGrammar.Pairs(pair: brackets),
            surroundingPairs: NovaGrammar.Pairs(pair: surroundingPairs),
            scopes: NovaGrammar.Scopes(scopes: scopes),
            collections: NovaGrammar.Collections(collection: collections))
    }
}
