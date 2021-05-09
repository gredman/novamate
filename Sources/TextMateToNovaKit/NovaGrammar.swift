import Foundation

import XMLCoder

public struct NovaGrammar: Encodable {
    let name: String
    let meta: Meta
    let detectors: [Detector]
    let scopes: Scopes
    let collections: Collections

    public struct Meta: Encodable {
        let name: String
        let type = "compiled"
        let preferredFileExtension: String?
    }

    public struct Detector: Encodable {
        let `extension`: Extension

        public struct Extension: Codable, DynamicNodeEncoding {
            let priority: Double
            let value: String

            enum CodingKeys: String, CodingKey {
                case priority
                case value = ""
            }

            public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
                switch key {
                case CodingKeys.priority: return .attribute
                default: return .element
                }
            }
        }
    }

    public struct Scopes: Encodable {
        let scope: [Scope]?
        let include: [Include]?

        static let empty = Scopes(scope: [], include: [])
    }

    public struct Collections: Encodable {
        public let collection: [Collection]

        public struct Collection: Encodable, DynamicNodeEncoding {
            let name: String
            let scope: [Scope]?
            let include: [Include]?

            public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
                switch key.stringValue {
                case "name": return .attribute
                default: return .element
                }
            }
        }
    }

    public struct Scope: Encodable, DynamicNodeEncoding {
        let name: String?
        let expression: Pattern?
        let startsWith: Pattern?
        let endsWith: Pattern?
        let subscopes: Scopes?

        var isEmpty: Bool {
            let all: [Any?] = [
                name,
                expression,
                startsWith,
                endsWith,
                subscopes
            ]
            return all.allSatisfy { $0 == nil }
        }

        public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
            switch key.stringValue {
            case "name": return .attribute
            default: return .element
            }
        }

        enum CodingKeys: String, CodingKey {
            case name
            case expression = ""
            case startsWith
            case endsWith
            case subscopes
        }

        public struct Pattern: Encodable {
            let expression: String
            let captures: [Capture]?

            public enum CodingKeys: String, CodingKey {
                case expression
                case capture
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(expression, forKey: .expression)
                for capture in captures ?? [] {
                    try container.encode(capture, forKey: .capture)
                }
            }

            public struct Capture: Encodable, DynamicNodeEncoding {
                let number: Int
                let name: String?

                public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
                    .attribute
                }
            }
        }
    }

    public struct Include: Encodable, DynamicNodeEncoding {
        let syntax = "self"
        @Trimmed(characterSet: CharacterSet(charactersIn: "#")) var collection: String = ""

        public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
            .attribute
        }
    }
}

extension NovaGrammar: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key.stringValue {
        case "name":
            return .attribute
        default:
            return .element
        }
    }
}

@propertyWrapper
public struct Trimmed: Encodable {
    public let wrappedValue: String

    public init(wrappedValue: String, characterSet: CharacterSet) {
        self.wrappedValue = wrappedValue.trimmingCharacters(in: characterSet)
    }

    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}
