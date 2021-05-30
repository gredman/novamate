import Foundation

public struct VSCodeLanguageConfiguration: Decodable {
    let comments: Comments
    let brackets: [Pair]
    let surroundingPairs: [Pair]

    struct Comments: Decodable {
        let lineComment: String?
        let blockComment: Pair?
    }

    struct Pair: Decodable {
        let first: String
        let last: String

        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            first = try container.decode(String.self)
            last = try container.decode(String.self)
        }
    }
}

public extension VSCodeLanguageConfiguration {
    init(url: URL) throws {
        Console.debug("loading language configuration from \(url.absoluteString)")
        let data = try Data(contentsOf: url)
        self = try JSONDecoder().decode(Self.self, from: data)
        Console.debug("language configuration loaded")
    }
}
