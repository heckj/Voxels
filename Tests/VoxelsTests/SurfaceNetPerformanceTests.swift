import Voxels
import XCTest

final class SurfaceNetPerformanceTests: XCTestCase {
    func testPerformanceInitialSurfaceNetPort() throws {
        let samples = try VoxelTestHelpers.voxelArrayFromSphere()

        // 0.189 sec
        measure {
            _ = try! VoxelMeshRenderer.surfaceNetMesh(
                sdf: samples,
                within: VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(32, 32, 32))
            )
        }
    }
}
