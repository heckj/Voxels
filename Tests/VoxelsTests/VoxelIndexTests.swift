import Voxels
import XCTest

class VoxelIndexTests: XCTestCase {
    func testIndexComparable() throws {
        XCTAssertTrue(VoxelIndex(0, 0, 0) < VoxelIndex(2, 2, 2))
        XCTAssertFalse(VoxelIndex(0, 0, 0) > VoxelIndex(2, 2, 2))
    }

    func testIndexEquatable() throws {
        XCTAssertTrue(VoxelIndex(0, 0, 0) != VoxelIndex(2, 2, 2))
        XCTAssertTrue(VoxelIndex(2, 2, 2) == VoxelIndex(2, 2, 2))
    }
}
