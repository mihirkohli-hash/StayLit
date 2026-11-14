// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SLTCommon",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "SLTCommon", targets: ["SLTCommon"]),
    ],
    targets: [
        .target(name: "SLTCommon"),
    ]
)
