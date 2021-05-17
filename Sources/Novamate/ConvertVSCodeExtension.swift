import ArgumentParser
import Foundation
import XMLCoder

import NovamateKit

struct ConvertVSCodeExtension: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "convert-extension")

    @Option(help: "Path to VS code language JSON") var json: URL

    @Flag(help: "Print debug info to stderr") var debug: Bool = false

    func run() throws {
        Console.debug = debug

        let vsCodeGrammar = try VSCodeGrammar(url: json)
        Console.debug("loaded \(vsCodeGrammar)")
    }
}
