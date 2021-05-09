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

    func run() throws {
        do {
            let textmate = try TextMateGrammar(url: input)
            let converted = NovaGrammar(textMateGrammar: textmate)
            let encoder = XMLEncoder()
            encoder.keyEncodingStrategy = .convertToKebabCase
            encoder.prettyPrintIndentation = .spaces(4)
            encoder.outputFormatting = [.prettyPrinted]
            let data = try encoder.encode(converted, withRootKey: "syntax")
            // Console.output("loaded grammar \(textmate)")
            // Console.output("converted converted \(converted)")
            Console.output("\(String(data: data, encoding: .utf8)!)")
        } catch {
            Console.error("failed: \(error.localizedDescription) \(type(of: error))")
            if let codingError = error as? DecodingError {
                Console.error("decoding error: \(codingError.debugDescription)")
            }
        }
    }
}
