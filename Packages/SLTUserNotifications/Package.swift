// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SLTUserNotifications",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "SLTUserNotifications", targets: ["SLTUserNotifications"]),
    ],
    dependencies: [
        .package(name: "SLTCommon", path: "../SLTCommon"),
    ],
    targets: [
        .target(
            name: "SLTUserNotifications",
            dependencies: [
                .product(name: "SLTCommon", package: "SLTCommon"),
            ]
        ),
    ]
)
