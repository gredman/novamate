import ArgumentParser
import Foundation
import XMLCoder

import NovamateKit

struct ConvertVSCodeExtension: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "convert-extension")

    @Argument(help: ArgumentHelp("Path to VS code extension", valueName: "path")) var extensionURL: URL
    @Option(help: "Name of language in extension") var languageName: String?
    @Flag(help: "Print debug info to stderr") var debug: Bool = false

    private var vsCodeExtension: VSCodeExtension?
    private var language: VSCodeExtension.Contributes.Language?
    private var grammarURL: URL?

    mutating func validate() throws {
        let vsCodeExtension = try VSCodeExtension(url: extensionURL)

        let language: VSCodeExtension.Contributes.Language
        if let name = languageName {
            if let lang = vsCodeExtension.language(withName: name) {
                language = lang
            } else {
                throw ValidationError("no language named \(name) in extension \(extensionURL.standardizedFileURL.path). options are \(vsCodeExtension.formattedLanguageNames)")
            }
        } else {
            if vsCodeExtension.contributes.languages.count > 1 {
                throw ValidationError("multiple languages in \(extensionURL.standardizedFileURL.path), please specify which. options are \(vsCodeExtension.formattedLanguageNames)")
            } else if let lang = vsCodeExtension.contributes.languages.first {
                language = lang
            } else {
                throw ValidationError("no languages in \(extensionURL.standardizedFileURL.path)")
            }
        }

        guard let grammar = vsCodeExtension.grammar(withName: language.id) else {
            throw ValidationError("no grammar found for language \(language.id)")
        }

        self.vsCodeExtension = vsCodeExtension
        self.language = language
        self.grammarURL = extensionURL.appendingPathComponent(grammar.path)
    }

    func run() throws {
        Console.debug = debug

        let grammarURL = self.grammarURL!
        Console.debug("loading grammar from \(grammarURL)")
        let grammar = try VSCodeGrammar(url: grammarURL)
        Console.debug("loaded grammar \(grammar)")

        let converted = NovaGrammar(extension: vsCodeExtension!, language: language!, grammar: grammar)
        Console.debug("converted grammar \(converted)")

        let encoder = XMLEncoder.forNovaGrammar()
        let data = try encoder.encode(converted, withRootKey: "syntax")
        Console.output(String(data: data, encoding: .utf8)!)
    }
}

private extension VSCodeExtension {
    var formattedLanguageNames: String {
        let names = contributes.languages
        return ListFormatter().string(from: names)!
    }

    func grammar(withName name: String) -> Contributes.Grammar? {
        contributes.grammars.first { $0.language == name }
    }

    func language(withName name: String) -> Contributes.Language? {
        contributes.languages.first { $0.id == name }
    }
}
