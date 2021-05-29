import XMLCoder

extension XMLEncoder {
    static func forNovaGrammar() -> XMLEncoder {
        let encoder = XMLEncoder()
        encoder.keyEncodingStrategy = .convertToKebabCase
        encoder.prettyPrintIndentation = .spaces(4)
        encoder.outputFormatting = [.prettyPrinted]
        return encoder
    }
}
