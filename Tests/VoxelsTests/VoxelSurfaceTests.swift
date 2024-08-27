@testable import Voxels
import XCTest

class VoxelSurfaceTests: XCTestCase {
    func testOpaqueSurface() throws {
        var fiveByFive = VoxelHash<Int>()

        // create cube in the middle
        for i in 1 ... 3 {
            for j in 1 ... 3 {
                for k in 1 ... 3 {
                    fiveByFive.set(VoxelIndex(i, j, k), newValue: 1)
                }
            }
        }

        let center = try XCTUnwrap(fiveByFive.value(VoxelIndex(x: 2, y: 2, z: 2)))
        XCTAssertTrue(center.isOpaque())
        XCTAssertFalse(try fiveByFive.isSurface((2, 2, 2)))

        XCTAssertTrue(try fiveByFive.isSurface((1, 1, 1)))
        XCTAssertTrue(try fiveByFive.isSurface((3, 3, 3)))
    }

    func testOpaqueSurfaceHashOutOfBounds() throws {
        let fiveByFive = VoxelHash<Int>()
        XCTAssertThrowsError(try fiveByFive.isSurface((0, 0, 0)))
        XCTAssertFalse(try fiveByFive.isSurface((9, 9, 9)))
    }

    func testOpaqueSurfaceArrayOutOfBounds() throws {
        let fiveByFive = VoxelArray(edge: 5, value: 0)
        XCTAssertThrowsError(try fiveByFive.isSurface((0, 0, 0)))
        XCTAssertThrowsError(try fiveByFive.isSurface((9, 9, 9)))
    }

    func testSurfaceFaces() throws {
        var fiveByFive = VoxelHash<Int>()

        // create cube in the middle
        for i in 1 ... 3 {
            for j in 1 ... 3 {
                for k in 1 ... 3 {
                    fiveByFive.set(VoxelIndex(i, j, k), newValue: 1)
                }
            }
        }

        // crossing the edge into the cube
        XCTAssertTrue(try fiveByFive.isSurfaceFace(VoxelIndex(0, 3, 3), direction: .x))

        // crossing the edge out of the cube
        XCTAssertTrue(try fiveByFive.isSurfaceFace(VoxelIndex(1, 1, 1), direction: .yneg))

        // outside the cube
        XCTAssertFalse(try fiveByFive.isSurfaceFace(VoxelIndex(0, 3, 3), direction: .y))

        // in the center of that solid cube
        XCTAssertFalse(try fiveByFive.isSurfaceFace(VoxelIndex(2, 2, 2), direction: .x))
    }
}
