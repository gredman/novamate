import ArgumentParser
import Foundation
import XMLCoder

import NovamateKit

struct ConvertLanguage: ParsableCommand {
    @Option(help: "Path to .tmLanguage file") var languageFile: URL

    @Flag(help: "Print debug info to stderr") var debug: Bool = false

    func run() throws {
        do {
            Console.debug = debug

            let textmate = try TextMateGrammar(url: languageFile)
            Console.debug("loaded grammar \(textmate)")

            let converted = NovaGrammar(textMateGrammar: textmate)
            Console.debug("converted \(converted)")

            let encoder = XMLEncoder()
            encoder.keyEncodingStrategy = .convertToKebabCase
            encoder.prettyPrintIndentation = .spaces(4)
            encoder.outputFormatting = [.prettyPrinted]

            let data = try encoder.encode(converted, withRootKey: "syntax")
            Console.output("\(String(data: data, encoding: .utf8)!)")
        } catch {
            Console.error("failed: \(error.localizedDescription) \(type(of: error))")
            if let codingError = error as? DecodingError {
                Console.error("decoding error: \(codingError.debugDescription)")
            }
        }
    }
}
