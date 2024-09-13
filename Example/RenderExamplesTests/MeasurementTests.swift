import Heightmap
import RealityKit
import RenderExamples
import Voxels
import XCTest

final class GeneralMeasurementTests: XCTestCase {
    func testGenerateHeightmap() throws {
        // ~ 0.361 seconds (full power, not battery)
        measure {
            let _ = Heightmap(width: 500, height: 500, seed: 437_347_632)
        }
    }

    func testGenerateVoxelHeightmap() throws {
        let heightmap = Heightmap(width: 500, height: 500, seed: 437_347_632)

        // ~ 10.9 seconds (full power, not battery)
        measure {
            let _ = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 200, voxelSize: 1.0)
        }
    }

    func testSurfaceNetRenderVoxelizedHeightmap() throws {
        let heightmap = Heightmap(width: 100, height: 100, seed: 437_347_632)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 100, voxelSize: 1.0)

        // ~ 6.1 seconds (full power, not battery)
        measure {
            let _ = try! SurfaceNetRenderer().render(voxelData: voxels,
                                                     scale: .init(),
                                                     within: voxels.bounds)
        }
    }

    func testMarchingCubesRenderVoxelizedHeightmap() throws {
        let heightmap = Heightmap(width: 100, height: 100, seed: 437_347_632)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 100, voxelSize: 1.0)

        // ~ 4.37 seconds (full power, not battery)
        measure {
            let _ = MarchingCubesRenderer().marching_cubes(data: voxels, scale: .init())
        }
    }

    func testBlockMeshRenderVoxelizedHeightmap() throws {
        let heightmap = Heightmap(width: 100, height: 100, seed: 437_347_632)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 100, voxelSize: 1.0)

        // ~ 0.91 seconds (full power, not battery)
        measure {
            let _ = VoxelMeshRenderer.fastBlockMeshSurfaceFaces(voxels, scale: .init(), within: voxels.bounds)
        }
    }

    func testNoiseHeightmapInitSpeed() throws {
        // ~ 1.4 sec (full power, not battery)
        measure {
            let _ = Heightmap(width: 1000, height: 1000, seed: 23623)
        }
    }
}
