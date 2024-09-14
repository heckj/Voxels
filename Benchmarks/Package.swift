// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "VoxelBenchmarks",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .executable(name: "voxel-benchmarks", targets: ["voxel-benchmarks"]),
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/tayloraswift/swift-noise", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "voxel-benchmarks",
            dependencies: [
                "Voxels",
                .product(name: "Noise", package: "swift-noise"),
                .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
            ]
        ),
    ]
)
