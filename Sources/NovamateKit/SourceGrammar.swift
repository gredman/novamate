import Foundation

public struct SourceGrammar: Codable {
    public let name: String
    public let scopeName: String
    public let fileTypes: [String]?

    public let patterns: [Rule]
    public let repository: [String: Rule]

    public struct Rule: Codable {
        var name: String?
        let contentName: String?
        let match, begin, end: String?
        let captures, beginCaptures, endCaptures: [Int: Capture]?
        let patterns: [Rule]?
        let include: String?

        public struct Capture: Codable {
            let name: String?
            let patterns: [Rule]?
        }

        public struct Identifier: Codable, Hashable, RawRepresentable {
            public let rawValue: String

            public init(rawValue: String) {
                self.rawValue = rawValue
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let text = try container.decode(String.self)
                self.init(rawValue: text)
            }
        }
    }
}

public extension SourceGrammar {
    init(url: URL) throws {
        Console.debug("loading grammar from \(url.absoluteString)")
        let data = try Data(contentsOf: url)
        switch url.pathExtension {
        case "json":
            Console.debug("decoding JSON")
            self = try JSONDecoder().decode(Self.self, from: data)
        case "tmLanguage":
            Console.debug("decoding plist")
            self = try PropertyListDecoder().decode(Self.self, from: data)
        default:
            throw GrammarError(errorDescription: "unknown file extension: \(url.pathExtension)")
        }
        Console.debug("grammar loaded")
    }
}

private struct GrammarError: LocalizedError {
    let errorDescription: String
}
