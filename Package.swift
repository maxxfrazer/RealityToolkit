// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RealityToolkit",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "RealityToolkit", targets: ["RealityToolkit"])
    ],
    dependencies: [],
    targets: [
        .target(name: "RealityToolkit", dependencies: []),
        .testTarget(name: "RealityToolkitTests", dependencies: ["RealityToolkit"])
    ]
)
