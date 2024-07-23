@testable import Voxels
import XCTest

class VoxelArrayTests: XCTestCase {
    func testVoxelArrayInitializer() throws {
        let v = VoxelArray(size: 3, value: 1)

        // internal access
        XCTAssertEqual(v._contents.count, 27)
        for internalValue in v._contents {
            XCTAssertEqual(internalValue, 1)
        }

        // indexing function
        XCTAssertEqual(v.indexFrom(0, 0, 0), 0)
        XCTAssertEqual(v.indexFrom(1, 1, 1), 13)
        XCTAssertEqual(v.indexFrom(2, 2, 2), 26)

        // external access
        XCTAssertEqual(v.value(x: 0, y: 0, z: 0), 1)
        XCTAssertEqual(v.value(x: 1, y: 1, z: 1), 1)
        XCTAssertEqual(v.value(x: 2, y: 2, z: 2), 1)
    }
}
