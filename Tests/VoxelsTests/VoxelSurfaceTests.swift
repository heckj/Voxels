@testable import Voxels
import XCTest

class VoxelSurfaceTests: XCTestCase {
    func testOpaqueSurface() throws {
        var fiveByFive = VoxelHash<Int>()

        // create cube in the middle
        for i in 1 ... 3 {
            for j in 1 ... 3 {
                for k in 1 ... 3 {
                    fiveByFive[SIMD3<Int>(i, j, k)] = 1
                }
            }
        }

        let center = try XCTUnwrap(fiveByFive.value(x: 2, y: 2, z: 2))
        XCTAssertTrue(center.isOpaque())
        XCTAssertFalse(try fiveByFive.isSurface(x: 2, y: 2, z: 2))

        XCTAssertTrue(try fiveByFive.isSurface(x: 1, y: 1, z: 1))
        XCTAssertTrue(try fiveByFive.isSurface(x: 3, y: 3, z: 3))
    }

    func testOpaqueSurfaceHashOutOfBounds() throws {
        let fiveByFive = VoxelHash<Int>()
        XCTAssertThrowsError(try fiveByFive.isSurface(x: 0, y: 0, z: 0))
        XCTAssertFalse(try fiveByFive.isSurface(x: 9, y: 9, z: 9))
    }

    func testOpaqueSurfaceArrayOutOfBounds() throws {
        let fiveByFive = VoxelArray(edge: 5, value: 0)
        XCTAssertThrowsError(try fiveByFive.isSurface(x: 0, y: 0, z: 0))
        XCTAssertThrowsError(try fiveByFive.isSurface(x: 9, y: 9, z: 9))
    }
}
