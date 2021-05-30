import ArgumentParser
import Foundation
import XMLCoder

import NovamateKit

struct ConvertLanguage: ParsableCommand {
    @Argument(help: "Path to .tmLanguage file") var languageFile: URL
    @Option(help: "Scope replacements of the form `from.scope.name:to.scope.name`") var replace = [ScopeReplacement]()

    @Flag(help: "Print debug info to stderr") var debug: Bool = false

    func run() throws {
        Console.debug = debug

        let textmate = try TextMateGrammar(url: languageFile)
        Console.debug("loaded grammar \(textmate)")

        let converted = NovaGrammar(textMateGrammar: textmate, replacements: replace)
        Console.debug("converted \(converted)")

        let encoder = XMLEncoder.forNovaGrammar()
        let data = try encoder.encode(converted, withRootKey: "syntax")
        Console.output("\(String(data: data, encoding: .utf8)!)")
    }
}
