import ArgumentParser

import NovamateKit

extension ScopeReplacement: ExpressibleByArgument {
    public init?(argument: String) {
        let components = argument.split(separator: ":")
        guard components.count == 2 else {
            return nil
        }
        self.init(from: String(components.first!), to: String(components.last!))
    }
}
