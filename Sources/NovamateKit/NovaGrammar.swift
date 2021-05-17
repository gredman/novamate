import Foundation

import XMLCoder

public struct NovaGrammar: Encodable {
    let name: String
    let meta: Meta
    let detectors: Detectors
    let brackets: Pairs
    let surroundingPairs: Pairs
    let scopes: Scopes
    let collections: Collections

    public struct Meta: Encodable {
        let name: String
        let type = "compiled"
        let preferredFileExtension: String?
    }

    public struct Detectors: Encodable {
        let `extension`: [Extension]

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

    public struct Pairs: Encodable {
        let pair: [Pair]

        public struct Pair: Encodable, DynamicNodeEncoding {
            let open, close: String

            public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
                .attribute
            }
        }
    }

    public struct Scopes: Encodable {
        let scope: [Scope]
        let include: [Scope]

        init(scopes: [Scope]) {
            scope = scopes.filter(\.isScope)
            include = scopes.filter(\.isInclude)
        }
    }

    public struct Collections: Encodable {
        public let collection: [Collection]

        public struct Collection: Encodable, DynamicNodeEncoding {
            let name: String
            let scope: [Scope]?
            let include: [Scope]?

            init(name: String, scopes: [Scope]) {
                self.name = name
                scope = scopes.filter(\.isScope)
                include = scopes.filter(\.isInclude)
            }

            public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
                switch key.stringValue {
                case "name": return .attribute
                default: return .element
                }
            }
        }
    }

    public enum Scope: Encodable, DynamicNodeEncoding {
        case match(Match)
        case startEnd(StartEnd)
        case include(Include)

        var isScope: Bool {
            switch self {
            case .match, .startEnd:
                return true
            default:
                return false
            }
        }

        var isInclude: Bool {
            switch self {
            case .include:
                return true
            default:
                return false
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case let .match(match):
                try match.encode(to: encoder)
            case let .startEnd(startEnd):
                try startEnd.encode(to: encoder)
            case let .include(include):
                try include.encode(to: encoder)
            }
        }

        public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
            switch key.stringValue {
            case "name", "syntax", "collection": return .attribute
            default: return .element
            }
        }

        public struct Pattern: Encodable {
            let expression: String
            let capture: [Capture]?

            public struct Capture: Encodable, DynamicNodeEncoding {
                let number: Int
                let name: String?

                public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
                    .attribute
                }
            }
        }

        public struct Match: Encodable, DynamicNodeEncoding {
            let name: String?
            let expression: String
            let capture: [Capture]?

            public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
                switch key.stringValue {
                case "name": return .attribute
                default: return .element
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

        public struct StartEnd: Encodable, DynamicNodeEncoding {
            let name: String?
            let startsWith: Pattern
            let endsWith: Pattern
            let subscopes: Scopes

            public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
                switch key.stringValue {
                case "name": return .attribute
                default: return .element
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
