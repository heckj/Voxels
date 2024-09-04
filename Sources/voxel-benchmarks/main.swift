import CollectionsBenchmark
import Foundation
import Voxels

// NOTE(heckj): benchmark implementations can be a bit hard to understand from the opaque inputs and structure of the code.
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
    var voxelHash = VoxelHash(defaultVoxel: Float.greatestFiniteMagnitude)
    for i in input {
        let index = bounds._unchecked_delinearize(i)
        voxelHash[index] = -1
    }
    precondition(voxelHash.count == input.count)
    blackHole(voxelHash)
}

// benchmark.add(
//    title: "Set remove",
//    input: ([Int], [Int]).self
// ) { input, removals in
//    { timer in
//        var set = Set<Int>(input)
//        timer.measure {
//            for i in removals {
//                set.remove(i)
//            }
//        }
//        precondition(set.count == 0)
//        blackHole(set)
//    }
// }

// Execute the benchmark tool with the above definitions.
benchmark.main()
