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
        // Tree-sitter language parsers
        .package(url: "https://github.com/alex-pinkus/tree-sitter-swift", branch: "main"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-javascript", branch: "master"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-python", branch: "master"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-rust", branch: "master"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-go", branch: "master"),
        .package(url: "https://github.com/tree-sitter/tree-sitter-json", branch: "master"),
    ],
    targets: [
        .executableTarget(
            name: "Prism",
            dependencies: [
                .product(name: "SwiftTreeSitter", package: "SwiftTreeSitter"),
                .product(name: "TreeSitterSwift", package: "tree-sitter-swift"),
                .product(name: "TreeSitterJavaScript", package: "tree-sitter-javascript"),
                .product(name: "TreeSitterPython", package: "tree-sitter-python"),
                .product(name: "TreeSitterRust", package: "tree-sitter-rust"),
                .product(name: "TreeSitterGo", package: "tree-sitter-go"),
                .product(name: "TreeSitterJSON", package: "tree-sitter-json"),
            ],
            path: "Sources/Prism",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
