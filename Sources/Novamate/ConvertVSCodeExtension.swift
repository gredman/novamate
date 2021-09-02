import ArgumentParser
import Foundation
import XMLCoder

import NovamateKit

struct ConvertVSCodeExtension: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "convert-extension")

    @Argument(help: ArgumentHelp("Path to VS code extension", valueName: "path")) var extensionURL: URL
    @Option(help: "Name of language in extension") var languageName: String?
    @OptionGroup var options: Options

    private var vsCodeExtension: VSCodeExtension?
    private var language: VSCodeExtension.Contributes.Language?
    private var grammarURL: URL?
    private var configurationURL: URL?

    mutating func validate() throws {
        let vsCodeExtension = try VSCodeExtension(url: extensionURL)

        guard let languages = vsCodeExtension.contributes?.languages, !languages.isEmpty else {
            throw ValidationError("no languages in \(extensionURL.standardizedFileURL.path)")
        }
        guard let grammars = vsCodeExtension.contributes?.grammars, !grammars.isEmpty else {
            throw ValidationError("no grammars in \(extensionURL.standardizedFileURL.path)")
        }

        let language: VSCodeExtension.Contributes.Language
        if let name = languageName {
            if let lang = languages.first(where: \.id, equalTo: name) {
                language = lang
            } else {
                throw ValidationError("no language named \(name) in extension \(extensionURL.standardizedFileURL.path). options are \(vsCodeExtension.formattedLanguageNames!)")
            }
        } else {
            if languages.count > 1 {
                throw ValidationError("multiple languages in \(extensionURL.standardizedFileURL.path), please specify which. options are \(vsCodeExtension.formattedLanguageNames!)")
            } else {
                language = languages.first!
            }
        }

        guard let grammar = grammars.first(where: \.language, equalTo: language.id) else {
            throw ValidationError("no grammar found for language \(language.id)")
        }

        self.vsCodeExtension = vsCodeExtension
        self.language = language
        self.grammarURL = extensionURL.appendingPathComponent(grammar.path)
        self.configurationURL = language.configuration.map(extensionURL.appendingPathComponent)
    }

    func run() throws {
        Console.debug = options.debug

        let grammarURL = self.grammarURL!
        Console.debug("loading grammar from \(grammarURL)")
        let grammar = try SourceGrammar(url: grammarURL)
        Console.debug("loaded grammar \(grammar)")
        let configuration = try configurationURL.map { try VSCodeLanguageConfiguration(url: $0) }

        let converted = NovaGrammar(
            configuration: configuration,
            extension: vsCodeExtension!,
            language: language!,
            grammar: grammar,
            replacements: options.replace)
        Console.debug("converted grammar \(converted)")

        let encoder = XMLEncoder.forNovaGrammar()
        let data = try encoder.encode(converted, withRootKey: "syntax")
        Console.output(String(data: data, encoding: .utf8)!)
    }
}

private extension VSCodeExtension {
    var formattedLanguageNames: String? {
        guard let names = contributes?.languages else { return nil }
        return ListFormatter().string(from: names)
    }
}
