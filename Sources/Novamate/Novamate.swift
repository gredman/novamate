import ArgumentParser
import Foundation

import NovamateKit

private struct ValidationError: LocalizedError {
    let errorDescription: String
}

struct Options: ParsableArguments {
    @Option(help: "Scope replacements of the form `from.scope.name:to.scope.name`") var replace = [ScopeReplacement]()

    @Flag(help: "Use default scope replacements") var defaultReplacements = false
    @Flag(help: "Print debug info to stderr") var debug = false

    mutating func validate() throws {
        if defaultReplacements {
            replace = replace + [ScopeReplacement].defaults
        }
    }
}

struct Novamate: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "novamate",
        abstract: "Convert language grammars to Nova",
        version: "0.1.0",
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
            ConvertTextMateLanguage.self
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
