import ArgumentParser
import Foundation
private struct ValidationError: LocalizedError {
    let errorDescription: String
}

struct Novamate: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "novamate",
        abstract: "Convert language grammars to Nova",
        version: "0.0.0",
        subcommands: [
            TextMate.self,
            VSCode.self
        ])
}

struct TextMate: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "textmate",
        abstract: "Convert TextMate language grammars to Nova",
        subcommands: [
            ConvertTextMateBundle.self,
            ConvertLanguage.self
        ])
}

struct VSCode: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "vscode",
        abstract: "Convert VS Code language extensions to Nova",
        subcommands: [
            ConvertVSCodeExtension.self
        ])
}
