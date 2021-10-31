import ArgumentParser
import Foundation
import XMLCoder

import NovamateKit

struct ConvertTextMateBundle: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "convert-bundle")

    @Argument(help: "Path to .tmbundle file") var bundle: URL
    @Option(help: "Name of language in bundle") var languageName: String?
    @OptionGroup var options: Options

    func run() throws {
        Console.debug = options.debug

        let textMateBundle = try TextMateBundle(url: bundle)
        let grammarURL: URL
        if let languageName = languageName {
            guard let url = textMateBundle.grammarURLs.first(where: { url in
                url.lastPathComponentWithoutExtension == languageName
            }) else {
                throw ConversionError(errorDescription: "no language named \(languageName) in bundle \(bundle.absoluteString)")
            }
            grammarURL = url
        } else if textMateBundle.grammarURLs.isEmpty {
            throw ConversionError(errorDescription: "no languages in \(bundle.absoluteString)")
        } else if textMateBundle.grammarURLs.count > 1 {
            throw ConversionError(errorDescription: "multiple languages in \(bundle.absoluteString), please specify which")
        } else {
            grammarURL = textMateBundle.grammarURLs.first!
        }

        let textmate = try SourceGrammar(url: grammarURL)
        Console.debug("loaded grammar", textmate)

        let builder = NovaGrammarBuilder(sourceGrammar: textmate, replacements: options.replace)
        let converted = builder.fromTextMate(settings: textMateBundle.settings)
        Console.debug("converted", converted)

        let encoder = XMLEncoder.forNovaGrammar()
        let data = try encoder.encode(converted, withRootKey: "syntax")
        Console.output("\(String(data: data, encoding: .utf8)!)")
    }
}

private extension URL {
    var lastPathComponentWithoutExtension: String {
        lastPathComponent.replacingOccurrences(of: ".\(pathExtension)", with: "")
    }
}
