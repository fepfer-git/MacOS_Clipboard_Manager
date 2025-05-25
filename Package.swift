// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "ClipboardManager",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        // Add any external dependencies here if needed
    ],
    targets: [
        .executableTarget(
            name: "ClipboardManager",
            dependencies: [],
            path: "Sources"
        )
    ]
)