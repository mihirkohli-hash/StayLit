// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SLTApplicationSupport",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "SLTApplicationSupport", targets: ["SLTApplicationSupport"]),
    ],
    dependencies: [
        .package(name: "SLTCommon", path: "../SLTCommon"),
    ],
    targets: [
        .target(
            name: "SLTApplicationSupport",
            dependencies: [
                .product(name: "SLTCommon", package: "SLTCommon"),
            ]
        ),
        .testTarget(
            name: "SLTApplicationSupportTests",
            dependencies: ["SLTApplicationSupport"],
            resources: [
                .copy("Resources/TestBundle.bundle"),
            ]
        ),
    ]
)
