@testable import Voxels
import XCTest

final class RendererRebuildComparisonTests: XCTestCase {
    func testSurfaceNetRendererComparison() throws {
        let samples = try SampleMeshData.voxelArrayFromSphere()

        let originalResultBuffer = try VoxelMeshRenderer.surfaceNetMesh(
            sdf: samples,
            within: VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(32, 32, 32))
        )

        let newThing = SurfaceNetRenderer()
        let newResultBuffer = try newThing.render(voxelData: samples, scale: .init(), within: samples.bounds.insetQuadrant())

        XCTAssertEqual(Set(newResultBuffer.positions), Set(originalResultBuffer.positions))
        XCTAssertEqual(newResultBuffer.indices.count, originalResultBuffer.indices.count)

        XCTAssertTrue(newResultBuffer.positions.count > 1)
        XCTAssertTrue(newResultBuffer.indices.count > 1)
    }
}
