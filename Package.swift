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
        // Tree-sitter core
        .package(url: "https://github.com/ChimeHQ/SwiftTreeSitter", from: "0.8.0"),
    ],
    targets: [
        .executableTarget(
            name: "Prism",
            dependencies: [
                .product(name: "SwiftTreeSitter", package: "SwiftTreeSitter"),
            ],
            path: "Sources/Prism",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
