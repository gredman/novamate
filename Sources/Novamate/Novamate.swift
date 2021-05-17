import ArgumentParser
import Foundation
private struct ValidationError: LocalizedError {
    let errorDescription: String
}

struct Novamate: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "novamate",
        abstract: "Convert TextMate language grammars to Nova",
        version: "0.0.0",
        subcommands: [
            ConvertBundle.self,
            ConvertLanguage.self
        ])
}
