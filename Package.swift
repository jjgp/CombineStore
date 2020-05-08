// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "CombineStore",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "CombineStore", targets: ["CombineStore"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "CombineStore", dependencies: []),
        .testTarget(name: "CombineStoreTests", dependencies: ["CombineStore"]),
    ]
)
