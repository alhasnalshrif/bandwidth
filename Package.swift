// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BandwidthGuard",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "BandwidthGuard", targets: ["BandwidthGuard"]),
        .library(name: "BandwidthGuardCore", targets: ["BandwidthGuardCore"]),
        .library(name: "BandwidthGuardDiscovery", targets: ["BandwidthGuardDiscovery"]),
        .library(name: "BandwidthGuardUI", targets: ["BandwidthGuardUI"])
    ],
    targets: [
        .executableTarget(
            name: "BandwidthGuard",
            dependencies: [
                "BandwidthGuardCore",
                "BandwidthGuardDiscovery",
                "BandwidthGuardUI"
            ],
            path: "Apps/BandwidthGuard",
            sources: ["Sources"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "BandwidthGuardCore",
            path: "Modules/Core/Sources"
        ),
        .target(
            name: "BandwidthGuardDiscovery",
            dependencies: ["BandwidthGuardCore"],
            path: "Modules/Discovery/Sources"
        ),
        .target(
            name: "BandwidthGuardUI",
            dependencies: ["BandwidthGuardCore"],
            path: "Modules/UI/Sources"
        ),
        .testTarget(
            name: "BandwidthGuardCoreTests",
            dependencies: ["BandwidthGuardCore"],
            path: "Tests/BandwidthGuardCoreTests"
        )
    ]
)
