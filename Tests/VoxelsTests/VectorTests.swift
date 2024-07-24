@testable import Voxels
import XCTest

class VectorTests: XCTestCase {
    func testVectorAbs() throws {
        let v1 = Vector(1, 1, 1)
        let v2 = Vector(-1, 1, 1)
        XCTAssertEqual(v1.abs(), v2.abs())
    }

    func testVectorLengthSquared() throws {
        let v1 = Vector(1, 1, 1)
        XCTAssertEqual(v1.lengthSquared, 3)
    }
}
