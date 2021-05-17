// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "novamate",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "novamate", targets: ["Novamate"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.4.0")),
        .package(
        url: "https://github.com/MaxDesiatov/XMLCoder.git",
        .upToNextMajor(from: "0.12.0"))
    ],
    targets: [
        .target(
            name: "NovamateKit",
            dependencies: ["XMLCoder"]),
        .target(
            name: "Novamate",
            dependencies: ["NovamateKit", .product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .testTarget(
            name: "NovamateTests",
            dependencies: ["NovamateKit"]),
    ]
)
