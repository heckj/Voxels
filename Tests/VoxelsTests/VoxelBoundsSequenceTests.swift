@testable import Voxels
import XCTest

class VoxelBoundsSequenceTests: XCTestCase {
    func testVoxelBoundsSequence() throws {
        let bounds = VoxelBounds(min: (0, 0, 0), max: (4, 4, 4))
        var all: [VoxelIndex] = []
        for index in bounds {
            all.append(index)
        }
        XCTAssertEqual(all.count, 5 * 5 * 5)
    }

    func testVoxelBoundsCollection() throws {
        let bounds = VoxelBounds(min: (0, 0, 0), max: (4, 4, 4))
        XCTAssertEqual(bounds.startIndex, 0)
        XCTAssertEqual(bounds.endIndex, 5 * 5 * 5)
        XCTAssertEqual(bounds.count, 5 * 5 * 5)

        var all: [VoxelIndex] = []
        for i in bounds.startIndex ..< bounds.endIndex {
            all.append(bounds[i])
        }
        XCTAssertEqual(all.count, 5 * 5 * 5)
    }
}
