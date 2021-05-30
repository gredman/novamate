import ArgumentParser
import Foundation

import NovamateKit

private struct ValidationError: LocalizedError {
    let errorDescription: String
}

struct Options: ParsableArguments {
    @Option(help: "Scope replacements of the form `from.scope.name:to.scope.name`") var replace = [ScopeReplacement]()

    @Flag(help: "Print debug info to stderr") var debug: Bool = false
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
