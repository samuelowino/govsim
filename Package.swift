// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
let package = Package(
    name: "govsim",
    dependencies: [
        .package(
            url: "https://github.com/sbooth/CSQLite",
            exact: "3.53.3",
            traits: ["THREADSAFE_1"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "govsim",
            dependencies: ["CSQLite"]
        ),
        .testTarget(
            name: "govsimTests",
            dependencies: ["govsim","CSQLite"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
