import ArgumentParser
import Foundation
import XMLCoder

import NovamateKit

struct ConvertLanguage: ParsableCommand {
    @Argument(help: "Path to .tmLanguage file") var languageFile: URL

    @OptionGroup var options: Options

    func run() throws {
        Console.debug = options.debug

        let textmate = try TextMateGrammar(url: languageFile)
        Console.debug("loaded grammar \(textmate)")

        let converted = NovaGrammar(textMateGrammar: textmate, replacements: options.replace)
        Console.debug("converted \(converted)")

        let encoder = XMLEncoder.forNovaGrammar()
        let data = try encoder.encode(converted, withRootKey: "syntax")
        Console.output("\(String(data: data, encoding: .utf8)!)")
    }
}
