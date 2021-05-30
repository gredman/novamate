public struct ScopeReplacement {
    public let from: String
    public let to: String

    public init(from: String, to: String) {
        self.from = from
        self.to = to
    }
}

public extension Array where Element == ScopeReplacement {
    static let defaults = [
        ScopeReplacement(from: "constant.language", to: "value"),
        ScopeReplacement(from: "constant.numeric", to: "value.number"),
        ScopeReplacement(from: "entity.name.function", to: "identifier.function"),
        ScopeReplacement(from: "entity.name.tag", to: "tag"),
        ScopeReplacement(from: "entity.name.type", to: "identifier.type"),
        ScopeReplacement(from: "storage", to: "keyword"),
        ScopeReplacement(from: "variable.language", to: "identifier.core"),
        ScopeReplacement(from: "variable.parameter", to: "identifier.argument")
    ]
}
