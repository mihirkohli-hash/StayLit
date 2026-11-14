// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SLTStatusItemUI",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "SLTStatusItemUI", targets: ["SLTStatusItemUI"]),
    ],
    dependencies: [
        .package(name: "SLTApplicationSupport", path: "../SLTApplicationSupport"),
    ],
    targets: [
        .target(
            name: "SLTStatusItemUI",
            dependencies: [
                "SLTApplicationSupport"
            ]
        ),
        .testTarget(name: "SLTStatusItemUITests", dependencies: ["SLTStatusItemUI"]),
    ]
)
