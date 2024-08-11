@testable import Voxels
import XCTest

class VoxelNeighborsTests: XCTestCase {
    func testDistance() throws {
        XCTAssertEqual(Neighbors<Any>.manhattan_distance(from: SIMD3<Int>(0, 0, 0), to: SIMD3<Int>(0, 0, 1)), 1)

        XCTAssertEqual(Neighbors<Any>.manhattan_distance(from: SIMD3<Int>(0, 0, 0), to: SIMD3<Int>(0, 1, 1)), 2)

        XCTAssertEqual(Neighbors<Any>.manhattan_distance(from: SIMD3<Int>(0, 0, 0), to: SIMD3<Int>(1, 1, 1)), 3)
    }
}
