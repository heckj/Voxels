// swift-tools-version: 5.10

import PackageDescription

var globalSwiftSettings: [PackageDescription.SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency"),
    // Swift 6 enablement
    // .enableUpcomingFeature("StrictConcurrency")
    // .swiftLanguageVersion(.v5)
    .enableUpcomingFeature("ExistentialAny"),
    .enableExperimentalFeature("AccessLevelOnImport"),
    .enableUpcomingFeature("InternalImportsByDefault"),
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
        .executable(name: "voxel-benchmarks", targets: ["voxel-benchmarks"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "Voxels",
            dependencies: [],
            swiftSettings: globalSwiftSettings
        ),
        .testTarget(
            name: "VoxelsTests",
            dependencies: ["Voxels"]
        ),
        .executableTarget(
            name: "voxel-benchmarks",
            dependencies: [
                "Voxels",
                .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
            ]
        ),
    ]
)
