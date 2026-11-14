// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SLTDeviceInfo",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "SLTDeviceInfo", targets: ["SLTDeviceInfo"]),
    ],
    dependencies: [
        .package(name: "SLTCommon", path: "../SLTCommon"),
    ],
    targets: [
        .target(
            name: "SLTDeviceInfo",
            dependencies: [
                .product(name: "SLTCommon", package: "SLTCommon"),
            ]
        ),
    ]
)
