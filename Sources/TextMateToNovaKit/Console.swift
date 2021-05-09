import Foundation

public struct Console {
    private static let encoding = String.Encoding.utf8

    public static func output(_ string: String) {
        FileHandle.standardOutput.write(string.data(using: Self.encoding)!)
        FileHandle.standardOutput.write("\n".data(using: Self.encoding)!)
    }

    public static func error(_ string: String) {
        FileHandle.standardError.write(string.data(using: Self.encoding)!)
        FileHandle.standardError.write("\n".data(using: Self.encoding)!)
    }

    public static func debug(_ string: String) {
        FileHandle.standardError.write("[".data(using: Self.encoding)!)
        FileHandle.standardError.write(string.data(using: Self.encoding)!)
        FileHandle.standardError.write("]\n".data(using: Self.encoding)!)
    }
}
