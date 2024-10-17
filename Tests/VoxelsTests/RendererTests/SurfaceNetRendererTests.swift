import Voxels
import XCTest

final class SurfaceNetRendererTests: XCTestCase {
    func testSurfaceNetRendererYBlock() throws {
        let samples = SampleMeshData.flatYBlock()

        let newThing = SurfaceNetRenderer()
        let newResultBuffer = newThing.render(samples, scale: .init(), within: samples.bounds.expand(2))

        try newResultBuffer.validate()
        XCTAssertEqual(newResultBuffer.positions.count, 282)
        XCTAssertEqual(newResultBuffer.quads, 280)
    }

    func testSurfaceNetRendererSDFBrick() throws {
        let samples = SampleMeshData.SDFBrick()

        let newThing = SurfaceNetRenderer()
        let newResultBuffer = newThing.render(samples, scale: .init(), within: samples.bounds.expand(2))

        try newResultBuffer.validate()
        XCTAssertEqual(newResultBuffer.positions.count, 36)
        XCTAssertEqual(newResultBuffer.quads, 34)
    }
}
