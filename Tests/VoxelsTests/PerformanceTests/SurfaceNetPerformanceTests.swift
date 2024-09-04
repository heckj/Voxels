import Voxels
import XCTest

final class SurfaceNetPerformanceTests: XCTestCase {
    func testPerformanceInitialSurfaceNetPort() throws {
        let samples = try SampleMeshData.voxelArrayFromSphere()

        // 0.189 sec - original // initial 0.220
        // changing corners: 0.183, 0.184 // initial 0.216
        measure {
            _ = try! VoxelMeshRenderer.surfaceNetMesh(
                sdf: samples,
                within: VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(32, 32, 32))
            )
        }
    }

    func testPerformanceRemadeSurfaceNetPort() throws {
        let samples = try SampleMeshData.voxelArrayFromSphere()

        let thing = SurfaceNetRenderer()
        // 0.163, 0.165 sec - so very much on par with the original
        measure {
            _ = try! thing.render(voxelData: samples, scale: .init())
        }
    }

    func testBoundsIndices() throws {
        let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(32, 32, 32))

        // 0.012
        measure {
            _ = bounds.indices
        }
    }
}
