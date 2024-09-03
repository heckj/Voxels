import Voxels
import XCTest

final class SurfaceNetTests: XCTestCase {
    func testVoxelArraySampling() throws {
        let samples = try VoxelTestHelpers.voxelArrayFromSphere()
        let insides = samples.filter { val in
            val < 0
        }
        XCTAssertTrue(insides.count > 1)
    }

    func testExample() throws {
        let samples = try VoxelTestHelpers.voxelArrayFromSphere()
        let buffer = try VoxelMeshRenderer.surfaceNetMesh(
            sdf: samples,
            within: VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(32, 32, 32))
        )

        XCTAssertTrue(buffer.positions.count > 1)
    }
}
