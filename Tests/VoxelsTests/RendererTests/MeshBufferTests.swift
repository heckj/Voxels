import Voxels
import XCTest

class MeshBufferTests: XCTestCase {
    func testMeshBufferInitializer() throws {
        let buffer = MeshBuffer()
        XCTAssertTrue(buffer.indices.isEmpty)
        XCTAssertTrue(buffer.normals.isEmpty)
        XCTAssertTrue(buffer.positions.isEmpty)

        XCTAssertEqual(buffer.memSize, 0)
    }

    func testMeshBufferAddQuad() throws {
        var buffer = MeshBuffer()
        buffer.addQuadPoints(p1: SIMD3<Float>(0, 1, 0), p2: SIMD3<Float>(0, 0, 0), p3: SIMD3<Float>(1, 1, 0), p4: SIMD3<Float>(1, 0, 0))
        XCTAssertEqual(buffer.indices.count, 6)
        XCTAssertEqual(buffer.positions.count, 4)
        XCTAssertEqual(buffer.normals.count, 4)

        for i in buffer.indices {
            XCTAssertTrue(i < buffer.positions.count)
            XCTAssertTrue(i < buffer.normals.count)
        }

        XCTAssertEqual(buffer.memSize, 152)
    }

    func testMeshBufferClear() throws {
        var buffer = MeshBuffer()
        buffer.addQuadPoints(p1: SIMD3<Float>(0, 1, 0), p2: SIMD3<Float>(0, 0, 0), p3: SIMD3<Float>(1, 1, 0), p4: SIMD3<Float>(1, 0, 0))
        buffer.reset()

        XCTAssertTrue(buffer.indices.isEmpty)
        XCTAssertTrue(buffer.normals.isEmpty)
        XCTAssertTrue(buffer.positions.isEmpty)

        XCTAssertEqual(buffer.memSize, 0)
    }
}
