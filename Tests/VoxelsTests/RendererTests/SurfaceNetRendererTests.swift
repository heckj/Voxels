import Voxels
import XCTest

final class SurfaceNetRendererTests: XCTestCase {
    func testSurfaceNetRendererComparison() throws {
        let samples = try SampleMeshData.voxelArrayFromSphere()

        let originalResultBuffer = try VoxelMeshRenderer.surfaceNetMesh(
            sdf: samples,
            within: VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(32, 32, 32))
        )

        let newThing = SurfaceNetRenderer()
        let newResultBuffer = try newThing.render(voxelData: samples, scale: .init(), within: samples.bounds.insetQuadrant())

        XCTAssertEqual(newResultBuffer.positions, originalResultBuffer.positions)
        XCTAssertEqual(newResultBuffer.indices, originalResultBuffer.indices)

        XCTAssertTrue(newResultBuffer.positions.count > 1)
        XCTAssertTrue(newResultBuffer.indices.count > 1)
    }

    func testSurfaceNetRendererYBlock() throws {
        let samples = SampleMeshData.flatYBlock()

        let newThing = SurfaceNetRenderer()
        let newResultBuffer = try newThing.render(voxelData: samples, scale: .init(), within: samples.bounds)

        try newResultBuffer.validate()
        XCTAssertEqual(newResultBuffer.positions.count, 100)
        XCTAssertEqual(newResultBuffer.quads, 81)
    }

    func testSurfaceNetRendererSDFBrick() throws {
        let samples = SampleMeshData.SDFBrick()

        let newThing = SurfaceNetRenderer()
        let newResultBuffer = try newThing.render(voxelData: samples, scale: .init(), within: samples.bounds)

        try newResultBuffer.validate()
        XCTAssertEqual(newResultBuffer.positions.count, 24)
        XCTAssertEqual(newResultBuffer.quads, 17)
    }
}
