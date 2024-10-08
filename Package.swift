// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WitchHat",
    platforms: [
        .iOS(.v17),
        .macOS(.v11),
        .macCatalyst(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "WitchHat",
            targets: ["WitchHat"]),
    ],
    targets: [
        .target(
            name: "WitchHat"),

    ]
)
