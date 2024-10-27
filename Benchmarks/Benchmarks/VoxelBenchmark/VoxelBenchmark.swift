import Benchmark
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

let sizeToRender = XZIndex(x: 100, z: 100)
let heightToRender = 50
let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(sizeToRender.x, heightToRender, sizeToRender.z))

let benchmarks = {
    Benchmark("NoiseHeightmap") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(_ = Heightmap(width: 1025, height: 1025, seed: 437_347_632))
        }
    }

    Benchmark("ConvertHeightMapToVoxels") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(_ = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: heightToRender, voxelSize: 1.0))
        }
    }

    Benchmark("Render Block Mesh - Surface") { benchmark in
        var meshBuffer = MeshBuffer()
        for _ in benchmark.scaledIterations {
            blackHole(meshBuffer = BlockMeshRenderer().render(voxels, scale: .init(), within: bounds, surfaceOnly: true))
        }
    }

    Benchmark("Render Block Mesh - Cubes") { benchmark in
        var meshBuffer = MeshBuffer()
        for _ in benchmark.scaledIterations {
            blackHole(meshBuffer = BlockMeshRenderer().render(voxels, scale: .init(), within: bounds, surfaceOnly: false))
        }
    }

    Benchmark("Render Marching Cubes") { benchmark in
        var meshBuffer = MeshBuffer()
        for _ in benchmark.scaledIterations {
            blackHole(meshBuffer = MarchingCubesRenderer().render(voxels, scale: .init(), within: bounds))
        }
    }

    Benchmark("Render SurfaceNet") { benchmark in
        var meshBuffer = MeshBuffer()
        for _ in benchmark.scaledIterations {
            blackHole(meshBuffer = SurfaceNetRenderer().render(voxels, scale: .init(), within: bounds))
        }
    }

    Benchmark("VoxelArray iteration") { benchmark in
        var va = VoxelArray(bounds: VoxelBounds(min: (0, 0, 0), max: (999, 499, 999)), initialValue: 0)
        let seed = VoxelHash<Int>()
        for idx in VoxelBounds(min: (0, 0, 0), max: (999, 49, 999)) {
            seed[idx] = 1
        }
        for _ in benchmark.scaledIterations {
            va.updating(with: seed)
        }
    }
}
