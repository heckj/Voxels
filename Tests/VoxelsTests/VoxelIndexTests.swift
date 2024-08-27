import Voxels
import XCTest

class VoxelIndexTests: XCTestCase {
    func testIndexInit() throws {
        XCTAssertNotNil(VoxelIndex(0, 0, 0))
        XCTAssertNotNil(VoxelIndex(x: 0, y: 0, z: 0))

        XCTAssertNotNil(VoxelIndex(0, 0, 0))
        XCTAssertNotNil(VoxelIndex([0, 0, 0]))
        let xyz = [1, 1, 1]
        XCTAssertNotNil(VoxelIndex(xyz))
        let ijk = (2, 2, 2)
        XCTAssertNotNil(VoxelIndex(ijk))
    }

    func testIndexComparable() throws {
        XCTAssertTrue(VoxelIndex(0, 0, 0) < VoxelIndex(2, 2, 2))
        XCTAssertFalse(VoxelIndex(0, 0, 0) > VoxelIndex(2, 2, 2))
    }

    func testIndexEquatable() throws {
        XCTAssertTrue(VoxelIndex(0, 0, 0) != VoxelIndex(2, 2, 2))
        XCTAssertTrue(VoxelIndex(2, 2, 2) == VoxelIndex(2, 2, 2))
    }
}
