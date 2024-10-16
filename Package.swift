// swift-tools-version: 5.10
// Swift 5.9 to support Xcode 15.2 on GitHub Actions
// Swift 5.10 requires Xcode 15.4 in GitHub Actions

import PackageDescription

var globalSwiftSettings: [PackageDescription.SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency"),
    // Swift 6 enablement
    // .enableUpcomingFeature("StrictConcurrency")
    // .swiftLanguageVersion(.v5)
    .enableUpcomingFeature("ExistentialAny"),
    // .enableExperimentalFeature("AccessLevelOnImport"),
    // .enableUpcomingFeature("InternalImportsByDefault"),
]

let package = Package(
    name: "Voxels",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "Voxels",
            targets: ["Voxels"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/heckj/Heightmap", from: "0.6.0"),
        .package(url: "https://github.com/pointfreeco/swift-issue-reporting", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Voxels",
            dependencies: [
                .product(name: "Heightmap", package: "Heightmap"),
                .product(name: "IssueReporting", package: "swift-issue-reporting"),
            ],
            swiftSettings: globalSwiftSettings
        ),
        .testTarget(
            name: "VoxelsTests",
            dependencies: [
                "Voxels",
                .product(name: "Heightmap", package: "Heightmap"),
            ]
        ),
    ]
)
