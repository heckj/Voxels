import Voxels
import XCTest

class VoxelBoundsTests: XCTestCase {
    func testVoxelBoundsInitFromSequence() throws {
        let seq = [VoxelIndex(0, 0, 0), VoxelIndex(1, 1, 1), VoxelIndex(2, 2, 2), VoxelIndex(0, 1, 2)]
        let bounds = try XCTUnwrap(VoxelBounds(seq))
        XCTAssertEqual(bounds.min, VoxelIndex(0, 0, 0))
        XCTAssertEqual(bounds.max, VoxelIndex(2, 2, 2))
    }

    func testNonChangingAdd() throws {
        let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(2, 2, 2))
        let newBounds = bounds.adding(VoxelIndex(1, 1, 1))
        XCTAssertEqual(newBounds, bounds)
    }

    func testVoxelBoundsFailedIniti() throws {
        XCTAssertNil(VoxelBounds([]))
    }
}
