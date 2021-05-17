import Foundation

public struct VSCodeExtension: Codable {
    public let contributes: Contributes

    public struct Contributes: Codable {
        public let languages: [Language]
        public let grammars: [Grammar]

        public struct Language: Codable {
            public let id: String
            public let extensions: [String]
            public let configuration: String
        }

        public struct Grammar: Codable {
            public let language: String
            public let scopeName: String
            public let path: String
        }
    }
}

public extension VSCodeExtension {
    init(url: URL) throws {
        Console.debug("loading extension from \(url.absoluteString)")
        let packageURL = url.appendingPathComponent("package.json")
        let data = try Data(contentsOf: packageURL)
        self = try JSONDecoder().decode(Self.self, from: data)
        Console.debug("grammar loaded")
    }
}
