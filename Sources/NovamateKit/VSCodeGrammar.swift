import Foundation

public struct VSCodeGrammar: Codable {
    public let name: String
    public let scopeName: String

    public let patterns: [TextMateGrammar.Rule]
    public let repository: [String: TextMateGrammar.Rule]
}

public extension VSCodeGrammar {
    init(url: URL) throws {
        Console.debug("loading grammar from \(url.absoluteString)")
        let data = try Data(contentsOf: url)
        self = try JSONDecoder().decode(Self.self, from: data)
        Console.debug("grammar loaded")
    }
}
