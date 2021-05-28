import ArgumentParser
import Foundation
import XMLCoder

import NovamateKit

struct ConvertVSCodeExtension: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "convert-extension")

    @Argument(help: ArgumentHelp("Path to VS code extension", valueName: "path")) var extensionURL: URL
    @Option(help: "Name of language in extension") var languageName: String?
    @Flag(help: "Print debug info to stderr") var debug: Bool = false

    private var grammarURL: URL?

    mutating func validate() throws {
        let vsCodeExtension = try VSCodeExtension(url: extensionURL)
        if let languageName = languageName {
            guard let grammar = vsCodeExtension.contributes.grammars.first(where: { grammar in
                grammar.language == languageName
            }) else {
                throw ValidationError("no language named \(languageName) in extension \(extensionURL.standardizedFileURL.path). options are \(vsCodeExtension.formattedGrammarNames)")
            }
            grammarURL = extensionURL.appendingPathComponent(grammar.path)
        } else if vsCodeExtension.contributes.grammars.isEmpty {
            throw ValidationError("no languages in \(extensionURL.standardizedFileURL.path)")
        } else if vsCodeExtension.contributes.grammars.count > 1 {
            throw ValidationError("multiple languages in \(extensionURL.standardizedFileURL.path), please specify which. options are \(vsCodeExtension.formattedGrammarNames)")
        } else {
            let grammarPath = vsCodeExtension.contributes.grammars.first!.path
            grammarURL = extensionURL.appendingPathComponent(grammarPath)
        }
    }

    func run() throws {
        Console.debug = debug

        let grammarURL = self.grammarURL!
        Console.debug("loading grammar from \(grammarURL)")
        let grammar = try VSCodeGrammar(url: grammarURL)
        Console.debug("loaded grammar \(grammar)")
    }
}

private extension VSCodeExtension {
    var formattedGrammarNames: String {
        let names = contributes.grammars.map(\.language)
        return ListFormatter().string(from: names)!
    }
}
