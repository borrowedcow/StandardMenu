// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StandardMenu",
    platforms: [.macOS(.v10_11)],
    products: [
        .library(
            name: "StandardMenu",
            targets: ["StandardMenu"]),
    ],
    dependencies: [
        .package(url: "https://github.com/j-f1/MenuBuilder", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "StandardMenu",
            dependencies: ["MenuBuilder"]),
        .testTarget(
            name: "StandardMenuTests",
            dependencies: ["StandardMenu"]),
    ]
)
