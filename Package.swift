// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ai-commit",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "ai-commit", targets: ["ai-commit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "GitAICommitCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/GitAICommitCore"
        ),
        .executableTarget(
            name: "ai-commit",
            dependencies: [
                "GitAICommitCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/ai-commit"
        ),
        .testTarget(
            name: "GitAICommitCoreTests",
            dependencies: ["GitAICommitCore"],
            path: "Tests/GitAICommitCoreTests"
        )
    ]
)
