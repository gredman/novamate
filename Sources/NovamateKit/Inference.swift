import Foundation

extension NovaGrammarBuilder {
    func inferredName(for capture: SourceGrammar.Rule.Capture) -> ScopeName? {
        if let name = capture.name {
            return name
        }

        guard let patterns = capture.patterns, patterns.isEmpty == false else {
            return nil
        }

        let names = patterns.compactMap { pattern -> ScopeName? in
            self.inferredName(for: pattern)
        }

        if names.isEmpty {
            return nil
        }

        if names.count == 1, let name = names.first {
            Console.debug("inferred scope name \(name)")
            return name
        }

        let prefix = names.commonPrefix
        let suffix = names.commonSuffix
        if !prefix.isEmpty || !suffix.isEmpty {
            let inferred = ScopeName(components: prefix + suffix)
            Console.debug("inferred scope name \(inferred) from \(names)")
            return inferred
        }

        return nil
    }

    func inferredName(for rule: SourceGrammar.Rule) -> ScopeName? {
        if let name = rule.name {
            return name
        }

        guard let include = rule.include else {
            return nil
        }

        let ruleName = RuleName(rawValue: include.trimmingCharacters(in: CharacterSet(charactersIn: "#")))
        guard let rule = sourceGrammar.repository[ruleName] else {
            return nil
        }

        guard let name = rule.name else {
            return inferredName(for: rule)
        }

        return name
    }
}

private extension ScopeName {
    init(components: [String]) {
        rawValue = components.joined(separator: ".")
    }

    var components: [String] {
        rawValue.split(separator: ".").map(String.init)
    }
}

private extension Collection where Element == ScopeName {
    var commonPrefix: [String] {
        guard let first = first else { return [] }

        let firstComponents = first.components
        let otherComponents = dropFirst().map(\.components)
        if otherComponents.isEmpty {
            return firstComponents
        }

        var prefix = [String]()
        for index in firstComponents.indices {
            guard otherComponents.allSatisfy({ $0.count > index }) else { break }
            guard otherComponents.allSatisfy({ $0[index] == firstComponents[index] }) else { break }
            prefix.append(firstComponents[index])
        }

        return prefix
    }

    var commonSuffix: AnyCollection<String> {
        guard let first = first else { return AnyCollection([]) }

        let firstComponents = Array(first.components.reversed())
        let otherComponents = dropFirst().map(\.components).map { Array($0.reversed()) }
        if otherComponents.isEmpty {
            return AnyCollection(firstComponents)
        }

        var suffix = [String]()
        for index in firstComponents.indices {
            guard otherComponents.allSatisfy({ $0.count > index }) else { break }
            guard otherComponents.allSatisfy({ $0[index] == firstComponents[index] }) else {
                break
            }
            suffix.append(firstComponents[index])
        }

        return AnyCollection(suffix)
    }
}
