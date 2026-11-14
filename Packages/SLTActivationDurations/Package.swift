// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SLTActivationDurations",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "SLTActivationDurations", targets: ["SLTActivationDurations"]),
    ],
    dependencies: [
        .package(name: "SLTCommon", path: "../SLTCommon"),
    ],
    targets: [
        .target(
            name: "SLTActivationDurations",
            dependencies: [
                .product(name: "SLTCommon", package: "SLTCommon"),
            ]
        ),
        .testTarget(name: "SLTActivationDurationsTests", dependencies: ["SLTActivationDurations"]),
    ],
    cxxLanguageStandard: .cxx2b
)
