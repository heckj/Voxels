// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "VoxelBenchmarks",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .executable(name: "voxel-benchmarks", targets: ["voxel-benchmarks"]),
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/tayloraswift/swift-noise", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.1"),
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.4.0")),
    ],
    targets: [
        .executableTarget(
            name: "VoxelBenchmark",
            dependencies: [
                "Voxels",
                .product(name: "Noise", package: "swift-noise"),
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/VoxelBenchmark",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),
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
