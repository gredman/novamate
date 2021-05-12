import ArgumentParser
import Foundation
import XMLCoder

import TextMateToNovaKit

extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(fileURLWithPath: argument)
    }
}

struct TextMateToNova: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "tm2nova",
        abstract: "Convert TextMate language grammars to Nova",
        version: "0.0.0")

    @Option(help: "Input .tmLanguage file") var input: URL

    @Flag(help: "Print debug info to stderr") var debug: Bool = false

    func run() throws {
        do {
            Console.debug = debug

            let textmate = try TextMateGrammar(url: input)
            Console.debug("loaded grammar \(textmate)")

            let converted = NovaGrammar(textMateGrammar: textmate)
            Console.debug("converted converted \(converted)")

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
