import CollectionsBenchmark
import Foundation
import Heightmap
import Noise
import Voxels

public extension Heightmap {
    init(width: Int, height: Int, seed: Int) {
        var noisedata: [Float] = []
        let noise = GradientNoise2D(amplitude: 1, frequency: 0.01, seed: 235_926)
        // evaluation of noise results in a relatively slowly changing value between -1 and 1
        for linearIndex in 0 ..< (height * width) {
            let xzIndex = XZIndex.strideToXZ(linearIndex, width: width)
            let result = noise.evaluate(Double(xzIndex.x), Double(xzIndex.z))
            noisedata.append(Float((result + 1) / 2.0))
        }
        self.init(noisedata, width: width)
    }
}

let heightmap = Heightmap(width: 1025, height: 1025, seed: 437_347_632)
let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 50, voxelSize: 1.0)

// NOTE(heckj): benchmark implementations can be a bit hard to understand from the opaque inputs
// and structure of the code.
//
// It's worthwhile to look at existing benchmarks that Karoy created for swift-collections:
// - https://github.com/apple/swift-collections/blob/main/Benchmarks/Benchmarks/SetBenchmarks.swift
// - https://github.com/apple/swift-collections/blob/main/Benchmarks/Benchmarks/OrderedSetBenchmarks.swift
// - https://github.com/apple/swift-collections/blob/main/Benchmarks/Benchmarks/DictionaryBenchmarks.swift
//
// Implementation detail for the benchmarks. When they're running, each run has a "size" associated
// with it, and that flows to the inputs that the task provides to your closure. There are 4 different default
// 'input generators' registered and immediately available:
//
// Int.self
// [Int].self
// ([Int], [Int]).self
// Insertions.self
//
// These result an array of length 'size' with integers, in shuffled order. The last one is a set of array of random
// numbers where each number is within the range 0...i where i is the index of the element order. It's useful for
// testing random insertions.

var benchmark = Benchmark(title: "Voxels")

benchmark.addSimple(
    title: "VoxelHash<Float> insert",
    input: [Int].self
) { input in
    let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(1000, 1000, 1000))
    // var set = GSet<String, Int>(actorId: "A")
    var voxelHash = VoxelHash(defaultVoxel: Float(1.0))
    for i in input {
        let index = bounds._unchecked_delinearize(i)
        voxelHash[index] = -1
    }
    precondition(voxelHash.count == input.count)
    blackHole(voxelHash)
}

benchmark.add(
    title: "blockmesh render",
    input: Int.self,
    maxSize: 512
) { input in
    { timer in
        let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(input, 50, input))

        var meshBuffer = MeshBuffer()
        timer.measure {
            meshBuffer = VoxelMeshRenderer.fastBlockMeshSurfaceFaces(voxels,
                                                                     scale: .init(),
                                                                     within: bounds)
        }
        blackHole(meshBuffer)
    }
}

benchmark.add(
    title: "surfacenet render",
    input: Int.self,
    maxSize: 512
) { input in
    { timer in
        let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(input, 50, input))

        var meshBuffer = MeshBuffer()
        timer.measure {
            meshBuffer = try! SurfaceNetRenderer().render(voxelData: voxels,
                                                          scale: .init(),
                                                          within: bounds)
        }
        blackHole(meshBuffer)
    }
}

// let _ = MarchingCubesRenderer().marching_cubes(data: voxels, scale: .init())

// Execute the benchmark tool with the above definitions.
benchmark.main()
