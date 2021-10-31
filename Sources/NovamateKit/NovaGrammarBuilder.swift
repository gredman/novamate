public struct NovaGrammarBuilder {
    let sourceGrammar: SourceGrammar
    let replacements: [ScopeReplacement]

    public init(sourceGrammar: SourceGrammar, replacements: [ScopeReplacement]) {
        self.sourceGrammar = sourceGrammar
        self.replacements = replacements
    }
}
