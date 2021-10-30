import Foundation

public struct SourceGrammar: Codable {
    public let name: String
    public let scopeName: ScopeName
    public let fileTypes: [String]?

    public let patterns: [Rule]
    @DictionaryCoded public var repository: Repository

    public typealias Repository = [RuleName: Rule]

    public struct Rule: Codable {
        var name: ScopeName?
        let match, begin, end: String?
        let captures, beginCaptures, endCaptures: [Int: Capture]?
        let patterns: [Rule]?
        let include: String?

        public struct Capture: Codable {
            let name: ScopeName?
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

public struct ScopeName: Codable, Equatable, Hashable, RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct RuleName: Codable, Equatable, Hashable, LosslessStringConvertible, RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init?(_ description: String) {
        rawValue = description
    }

    public var description: String { rawValue }
}

@propertyWrapper
public struct DictionaryCoded<Key, Value>: Codable where Key: LosslessStringConvertible, Key: Hashable, Value: Codable {
    public let wrappedValue: [Key: Value]

    struct CodingKeys: CodingKey {
        public let intValue: Int? = nil
        public let stringValue: String
        public init?(stringValue: String) {
            self.stringValue = stringValue
        }
        public init?(intValue: Int) {
            return nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        for keyValue in wrappedValue {
            try container.encode(keyValue.value, forKey: CodingKeys(stringValue: keyValue.key.description)!)
        }
    }

    public init(from decoder: Decoder) throws {
        var result = [Key: Value]()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        for key in container.allKeys {
            let value = try container.decode(Value.self, forKey: key)
            result[Key(key.stringValue)!] = value
        }
        wrappedValue = result
    }
}
