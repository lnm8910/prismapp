// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Prism",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "Prism",
            targets: ["Prism"]
        )
    ],
    dependencies: [
        // Tree-sitter dependencies will be added in Phase 2
    ],
    targets: [
        .executableTarget(
            name: "Prism",
            dependencies: [],
            path: "Sources/Prism",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
