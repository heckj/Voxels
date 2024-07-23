@testable import Voxels
import XCTest

class VertexTests: XCTestCase {
    func testVertexInitializer() throws {
        let v = CompleteVertex(position: Vector(0, 0, 0))
        XCTAssertEqual(v.normal, .zero)
        XCTAssertEqual(v.uv, .zero)
    }

    func testVertexWith() throws {
        let v = CompleteVertex(position: Vector(0, 0, 0))
        XCTAssertEqual(v.normal, .zero)
        XCTAssertEqual(v.uv, .zero)
        let newV = v.withNormal(Vector(0, 0, 1))
        XCTAssertEqual(newV.normal, Vector(0, 0, 1))
        XCTAssertEqual(newV.uv, .zero)
    }

    func testVertexWithNonNormal() throws {
        let v = CompleteVertex(position: Vector(0, 0, 0))
        let newV = v.withNormal(Vector(0, 0, 10))
        XCTAssertEqual(newV.normal, Vector(0, 0, 1))
        XCTAssertEqual(newV.uv, .zero)
    }
}
