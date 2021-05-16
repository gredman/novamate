import ArgumentParser
import Foundation
private struct ValidationError: LocalizedError {
    let errorDescription: String
}

struct Novanate: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "tm2nova",
        abstract: "Convert TextMate language grammars to Nova",
        version: "0.0.0",
        subcommands: [
            ConvertBundle.self,
            ConvertLanguage.self
        ])
}
