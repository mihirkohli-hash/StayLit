// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SLTSleepWakeTimer",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "SLTSleepWakeTimer", targets: ["SLTSleepWakeTimer"]),
    ],
    dependencies: [
        .package(name: "SLTApplicationSupport", path: "../SLTApplicationSupport")
    ],
    targets: [
        .target(name: "SLTSleepWakeTimer", dependencies: ["SLTApplicationSupport"]),
    ]
)
