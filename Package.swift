// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "tm2nova",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "tm2nova", targets: ["TextMateToNova"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.4.0")),
        .package(
        url: "https://github.com/MaxDesiatov/XMLCoder.git",
        .upToNextMajor(from: "0.12.0"))
    ],
    targets: [
        .target(
            name: "TextMateToNovaKit",
            dependencies: ["XMLCoder"]),
        .target(
            name: "TextMateToNova",
            dependencies: ["TextMateToNovaKit", .product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .testTarget(
            name: "TextMateToNovaTests",
            dependencies: ["TextMateToNovaKit"]),
    ]
)
