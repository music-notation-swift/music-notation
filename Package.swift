// swift-tools-version:5.4.0
import PackageDescription

let package = Package(
    name: "music-notation",
    platforms: [
        // Add support for all platforms starting from a specific version.
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v7)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "music-notation",
            targets: ["music-notation"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "music-notation",
            dependencies: []),
        .testTarget(
            name: "music-notationTests",
            dependencies: ["music-notation"]),
    ]
)
