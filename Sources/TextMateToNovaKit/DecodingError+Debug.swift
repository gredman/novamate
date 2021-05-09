import Foundation

public extension DecodingError {
    var debugDescription: String {
        switch self {
            case let .dataCorrupted(context):
                return "dataCorrupted: \(context)"
            case let .keyNotFound(codingKey, context):
                return "keyNotFound: \(codingKey) in context \(context)"
            case let .typeMismatch(type, context):
                return "typeMismatch: \(type) in context \(context)"
            case let .valueNotFound(type, context):
                return "valueNotFound: \(type) in context \(context)"
            @unknown default:
                fatalError("unknown decoding error \(self)")
        }
    }
}
