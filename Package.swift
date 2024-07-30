// swift-tools-version:6.0
//
//  Package.swift
//  MusicNotation
//
//  Created by Steven Woolgar on 07/30/2021.
//  Copyright © 2021 Steven Woolgar. All rights reserved.
//
import PackageDescription

let package = Package(
    name: "music-notation",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10)
    ],

    products: [
    	.library(name: "MusicNotation", targets: ["MusicNotation"])],

    targets: [
        .target(name: "MusicNotation", path: "Sources", exclude: ["../docs"]),
        .testTarget(name: "MusicNotationTests", dependencies: ["MusicNotation"])
    ],

    swiftLanguageVersions: [.v6]
)
