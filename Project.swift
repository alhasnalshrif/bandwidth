import ProjectDescription

let project = Project(
    name: "BandwidthGuard",
    organizationName: "Alshrif",
    settings: .settings(
        base: [
            "MACOSX_DEPLOYMENT_TARGET": "14.0",
            "SWIFT_VERSION": "6.0",
        ]
    ),
    targets: [
        .target(
            name: "BandwidthGuard",
            destinations: .macOS,
            product: .app,
            productName: "Bandwidth Guard",
            bundleId: "com.alshrif.bandwidth",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Bandwidth Guard",
                    "LSUIElement": true,
                ]
            ),
            sources: ["Apps/BandwidthGuard/Sources/**/*.swift"],
            resources: ["Apps/BandwidthGuard/Resources/**"],
            dependencies: [
                .target(name: "BandwidthGuardCore"),
                .target(name: "BandwidthGuardDiscovery"),
                .target(name: "BandwidthGuardUI"),
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                    "CODE_SIGN_STYLE": "Automatic",
                    "DEVELOPMENT_TEAM": "LM9GJ6AQ87",
                    "ENABLE_HARDENED_RUNTIME": "YES",
                ]
            )
        ),
        .target(
            name: "BandwidthGuardCore",
            destinations: .macOS,
            product: .framework,
            bundleId: "com.alshrif.bandwidth.core",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["Modules/Core/Sources/**/*.swift"]
        ),
        .target(
            name: "BandwidthGuardNetworkExtension",
            destinations: .macOS,
            product: .appExtension,
            bundleId: "com.alshrif.bandwidth.network-extension",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .extendingDefault(
                with: [
                    "NSExtension": [
                        "NSExtensionPointIdentifier": "com.apple.networkextension.filter-data",
                        "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).FilterDataProvider",
                    ],
                ]
            ),
            sources: ["Extensions/BandwidthGuardNetworkExtension/Sources/**/*.swift"],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Automatic",
                    "DEVELOPMENT_TEAM": "LM9GJ6AQ87",
                    "ENABLE_HARDENED_RUNTIME": "YES",
                ]
            )
        ),
        .target(
            name: "BandwidthGuardDiscovery",
            destinations: .macOS,
            product: .framework,
            bundleId: "com.alshrif.bandwidth.discovery",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["Modules/Discovery/Sources/**/*.swift"],
            dependencies: [
                .target(name: "BandwidthGuardCore"),
            ]
        ),
        .target(
            name: "BandwidthGuardUI",
            destinations: .macOS,
            product: .framework,
            bundleId: "com.alshrif.bandwidth.ui",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["Modules/UI/Sources/**/*.swift"],
            dependencies: [
                .target(name: "BandwidthGuardCore"),
            ]
        ),
        .target(
            name: "BandwidthGuardCoreTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.alshrif.bandwidth.core.tests",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .default,
            sources: ["Tests/BandwidthGuardCoreTests/**/*.swift"],
            dependencies: [
                .target(name: "BandwidthGuardCore"),
            ]
        ),
    ],
    schemes: [
        .scheme(
            name: "BandwidthGuard",
            shared: true,
            buildAction: .buildAction(targets: ["BandwidthGuard"]),
            testAction: .targets(["BandwidthGuardCoreTests"], configuration: "Debug")
        ),
    ],
    additionalFiles: [
        "README.md",
        "CLAUDE.md",
        "CONTRIBUTING.md",
        "ARCHITECTURE.md",
        "LICENSE",
        "PROJECT_PLAN.md",
        "Package.swift",
        "Workspace.swift",
        "Tuist.swift",
        "mise.toml",
        ".swiftformat",
        ".swiftlint.yml",
        ".gitignore",
        ".githooks/**",
        "Scripts/**",
        ".github/**",
    ]
)
