// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "music-notation",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v7)
    ],
    products: [
    	.library(name: "MusicNotation", targets: ["MusicNotation"])],
    targets: [
        .target(name: "MusicNotation", path: "Sources", exclude: ["../docs"]),
        .testTarget(name: "MusicNotationTests", dependencies: ["MusicNotation"])
    ]
)
