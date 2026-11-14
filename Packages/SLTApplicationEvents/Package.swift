// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SLTApplicationEvents",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "SLTApplicationEvents", targets: ["SLTApplicationEvents"]),
    ],
    dependencies: [
        .package(name: "SLTCommon", path: "../SLTCommon"),
    ],
    targets: [
        .target(
            name: "SLTApplicationEvents",
            dependencies: [
                .product(name: "SLTCommon", package: "SLTCommon"),
            ]
        ),
        .testTarget(name: "SLTApplicationEventsTests", dependencies: ["SLTApplicationEvents"]),
    ]
)
