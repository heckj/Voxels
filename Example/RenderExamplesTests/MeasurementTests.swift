import Heightmap
import RealityKit
import RenderExamples
import Voxels
import XCTest

final class GeneralMeasurementTests: XCTestCase {
    func testGenerateHeightmap() throws {
        // ~ 0.361 seconds
        measure {
            let _ = Heightmap(width: 500, height: 500, seed: 437_347_632)
        }
    }

    func testGenerateVoxelHeightmap() throws {
        let heightmap = Heightmap(width: 500, height: 500, seed: 437_347_632)

        // ~ 12.2 seconds
        measure {
            let _ = VoxelHash<Float>.heightmap(heightmap,
                                               maxVoxelHeight: 200)
        }
    }

    func testSurfaceNetRenderVoxelizedHeightmap() throws {
        let heightmap = Heightmap(width: 100, height: 100, seed: 437_347_632)
        let voxels = VoxelHash<Float>.heightmap(heightmap,
                                                maxVoxelHeight: 200)

        // ~ 11.8 seconds
        measure {
            let _ = try! SurfaceNetRenderer().render(voxelData: voxels,
                                                     scale: .init(),
                                                     within: voxels.bounds)
        }
    }

    func testMarchingCubesRenderVoxelizedHeightmap() throws {
        let heightmap = Heightmap(width: 100, height: 100, seed: 437_347_632)
        let voxels = VoxelHash<Float>.heightmap(heightmap,
                                                maxVoxelHeight: 200)

        // ~ 8.47 seconds
        measure {
            let _ = MarchingCubesRenderer().marching_cubes(data: voxels, scale: .init())
        }
    }

    func testBlockMeshRenderVoxelizedHeightmap() throws {
        let heightmap = Heightmap(width: 100, height: 100, seed: 437_347_632)
        let voxels = VoxelHash<Float>.heightmap(heightmap,
                                                maxVoxelHeight: 200)

        // ~ 1.87 seconds
        measure {
            let _ = VoxelMeshRenderer.fastBlockMeshSurfaceFaces(voxels, scale: .init(), within: voxels.bounds)
        }
    }

    func testNoiseHeightmapInitSpeed() throws {
        // ~ 2.3 sec
        measure {
            let _ = Heightmap(width: 1000, height: 1000, seed: 23623)
        }
    }
}
