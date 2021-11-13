public extension SourceGrammar.Rule.Capture {
    var inferredName: ScopeName? {
        if let name = name {
            return name
        }

        guard let patterns = patterns, patterns.isEmpty == false else {
            return nil
        }

        if patterns.count == 1, let name = patterns.first?.name {
            return name
        }

        let names = patterns.compactMap(\.name)
        let prefix = names.commonPrefix
        let suffix = names.commonSuffix
        if !prefix.isEmpty || !suffix.isEmpty {
            let inferred = ScopeName(components: prefix + suffix)
            Console.debug("inferred scope name \(inferred) from \(names)")
            return inferred
        }

        return nil
    }
}

private extension ScopeName {
    init(components: [Substring]) {
        rawValue = components.joined(separator: ".")
    }

    var components: [Substring] {
        rawValue.split(separator: ".")
    }
}

private extension Collection where Element == ScopeName {
    var commonPrefix: [Substring] {
        guard let first = first else { return [] }

        let firstComponents = first.components
        let otherComponents = dropFirst().map(\.components)
        if otherComponents.isEmpty {
            return firstComponents
        }

        var prefix = [Substring]()
        for index in firstComponents.indices {
            guard otherComponents.allSatisfy({ $0.count > index }) else { break }
            guard otherComponents.allSatisfy({ $0[index] == firstComponents[index] }) else { break }
            prefix.append(firstComponents[index])
        }

        return prefix
    }

    var commonSuffix: AnyCollection<Substring> {
        guard let first = first else { return AnyCollection([]) }

        let firstComponents = Array(first.components.reversed())
        let otherComponents = dropFirst().map(\.components).map { Array($0.reversed()) }
        if otherComponents.isEmpty {
            return AnyCollection(firstComponents)
        }

        var suffix = [Substring]()
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
