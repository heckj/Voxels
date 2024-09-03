import Voxels
import XCTest

final class SurfaceNetRendererTests: XCTestCase {
    func testSurfaceNetRenderer() throws {
        let samples = try VoxelTestHelpers.voxelArrayFromSphere()

        let originalResultBuffer = try VoxelMeshRenderer.surfaceNetMesh(
            sdf: samples,
            within: VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(32, 32, 32))
        )

        let newThing = SurfaceNetRenderer()
        let newResultBuffer = try newThing.render(voxelData: samples, scale: .init())

        XCTAssertEqual(newResultBuffer.positions, originalResultBuffer.positions)
        XCTAssertEqual(newResultBuffer.indices, originalResultBuffer.indices)

        XCTAssertTrue(newResultBuffer.positions.count > 1)
        XCTAssertTrue(newResultBuffer.indices.count > 1)
    }
}
