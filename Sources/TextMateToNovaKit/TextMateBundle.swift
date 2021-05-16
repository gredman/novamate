import Foundation

public struct TextMateBundle {
    public var grammarURLs: [URL]
    public var settings: Settings

    public struct Settings {
        public var highlightPairs: [(String, String)] = []
        public var smartTypingPairs: [(String, String)] = []

        public init() {}

        mutating func update(with other: Settings) {
            highlightPairs = highlightPairs + other.highlightPairs
            smartTypingPairs = smartTypingPairs + other.smartTypingPairs
        }
    }
}

public struct PropertyListError: LocalizedError {
    public let errorDescription: String?
}

public extension TextMateBundle {
    init(url: URL) throws {
        let syntaxURL = URL(fileURLWithPath: "Syntaxes", relativeTo: url)
        grammarURLs = try FileManager.default.contentsOfDirectory(at: syntaxURL, includingPropertiesForKeys: [], options: [])
        .filter(by: \.pathExtension, equalTo: "tmLanguage")

        let preferencesURL = URL(fileURLWithPath: "Preferences", relativeTo: url)
        let preferencesURLs = try FileManager.default.contentsOfDirectory(at: preferencesURL, includingPropertiesForKeys: [], options: [])
            .filter(by: \.pathExtension, equalTo: "tmPreferences")

        settings = try preferencesURLs
            .map(TextMateBundle.Settings.init(url:))
            .reduce(into: TextMateBundle.Settings()) { acc, settings in acc.update(with: settings) }

    }
}

private extension TextMateBundle.Settings {
    init(url: URL) throws {
        Console.debug("reading preferences from \(url.absoluteString)")
        let data = try Data(contentsOf: url)
        let contents = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)

        guard let properties = contents as? [String: Any] else {
            throw PropertyListError(errorDescription: "property list at \(url.absoluteString) is not a dictionary")
        }

        let settings = try properties.properties(for: "settings")

        for key in settings.keys {
            switch key {
            case "highlightPairs":
                highlightPairs = try settings.stringPairs(for: key)
            case "smartTypingPairs":
                smartTypingPairs = try settings.stringPairs(for: key)
            default:
                Console.debug("unhandled property list key \(key) in \(url)")
            }
        }
    }
}

private extension Dictionary where Key == String, Value: Any {
    func properties(for key: String) throws -> [String: Any] {
        guard let value = self[key] as? [String: Any] else {
            throw PropertyListError(errorDescription: "property list value with key \(key) is not a dictionary")
        }
        return value
    }

    func stringPairs(for key: String) throws -> [(String, String)] {
        guard let value = self[key] as? [[String]] else {
            throw PropertyListError(errorDescription: "property list value with key \(key) is not a list of pairs of strings")
        }
        return value.map { array in (array[0], array[1]) }
    }
}
