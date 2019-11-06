// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RateKit",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "RateKit", targets: ["RateKit"]),
    ],
    targets: [
        .target(name: "RateKit", dependencies: [], path: "Sources"),
        .testTarget(name: "RateKitTests", dependencies: ["RateKit"]),
    ]
)
