import ArgumentParser
import Foundation
import XMLCoder

import NovamateKit

struct ConvertVSCodeExtension: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "convert-extension")

    @Argument(help: "Path to VS code extension") var `extension`: URL
    @Option(help: "Name of language in extension") var languageName: String?

    @Flag(help: "Print debug info to stderr") var debug: Bool = false

    func run() throws {
        Console.debug = debug

        let vsCodeExtension = try VSCodeExtension(url: `extension`)
        Console.debug("loaded extension \(vsCodeExtension)")

        let grammarURL: URL
        if let languageName = languageName {
            guard let grammar = vsCodeExtension.contributes.grammars.first(where: { grammar in
                grammar.language == languageName
            }) else {
                throw ConversionError(errorDescription: "no language named \(languageName) in extension \(`extension`.absoluteString)")
            }
            grammarURL = `extension`.appendingPathComponent(grammar.path)
        } else if vsCodeExtension.contributes.grammars.isEmpty {
            throw ConversionError(errorDescription: "no languages in \(`extension`.absoluteString)")
        } else if vsCodeExtension.contributes.grammars.count > 1 {
            throw ConversionError(errorDescription: "multiple languages in \(`extension`.absoluteString), please specify which")
        } else {
            let path = vsCodeExtension.contributes.grammars.first!.path
            grammarURL = `extension`.appendingPathComponent(path)
        }

        Console.debug("loading grammar from \(grammarURL)")
        let grammar = try VSCodeGrammar(url: grammarURL)
        Console.debug("loaded grammar \(grammar)")
    }
}
