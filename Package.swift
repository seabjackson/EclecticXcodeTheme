// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EclecticTheme",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        .executableTarget(
            name: "EclecticTheme",
            dependencies: ["ZIPFoundation"],
            resources: [.process("Resources")]
        )
    ]
)
