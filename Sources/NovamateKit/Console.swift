import Foundation

public struct Console {
    public static var debug = false

    public static func output(_ string: String) {
        FileHandle.standardOutput.write(string)
        FileHandle.standardOutput.write("\n")
    }

    public static func error(_ string: String) {
        FileHandle.standardError.write("***")
        FileHandle.standardError.write(string)
        FileHandle.standardError.write("\n")
    }

    public static func debug(_ string: String) {
        guard debug else { return }
        FileHandle.standardError.write("[")
        FileHandle.standardError.write(string)
        FileHandle.standardError.write("]\n\n")
    }
}

private extension FileHandle {
    private static let encoding = String.Encoding.utf8

    func write(_ text: String) {
        write(text.data(using: Self.encoding)!)
    }
}
