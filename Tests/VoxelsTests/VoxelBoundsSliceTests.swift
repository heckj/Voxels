@testable import Voxels
import XCTest

class VoxelBoundsSliceTests: XCTestCase {
    func testSliceX() throws {
        let initial = VoxelBounds(min: (0, 0, 0), max: (10, 10, 10))

        // overslice
        XCTAssertEqual(initial.x(-4 ... 13), initial)

        // overlap high
        XCTAssertEqual(initial.x(3 ... 13), VoxelBounds(min: (3, 0, 0), max: (10, 10, 10)))

        // overlay low
        XCTAssertEqual(initial.x(-3 ... 5), VoxelBounds(min: (0, 0, 0), max: (5, 10, 10)))

        // inside slice
        XCTAssertEqual(initial.x(3 ... 5), VoxelBounds(min: (3, 0, 0), max: (5, 10, 10)))
    }

    func testSliceY() throws {
        let initial = VoxelBounds(min: (0, 0, 0), max: (10, 10, 10))

        // overslice
        XCTAssertEqual(initial.y(-4 ... 13), initial)

        // overlap high
        XCTAssertEqual(initial.y(3 ... 13), VoxelBounds(min: (0, 3, 0), max: (10, 10, 10)))

        // overlay low
        XCTAssertEqual(initial.y(-3 ... 5), VoxelBounds(min: (0, 0, 0), max: (10, 5, 10)))

        // inside slice
        XCTAssertEqual(initial.y(3 ... 5), VoxelBounds(min: (0, 3, 0), max: (10, 5, 10)))
    }

    func testSliceZ() throws {
        let initial = VoxelBounds(min: (0, 0, 0), max: (10, 10, 10))

        // overslice
        XCTAssertEqual(initial.z(-4 ... 13), initial)

        // overlap high
        XCTAssertEqual(initial.z(3 ... 13), VoxelBounds(min: (0, 0, 3), max: (10, 10, 10)))

        // overlay low
        XCTAssertEqual(initial.z(-3 ... 5), VoxelBounds(min: (0, 0, 0), max: (10, 10, 5)))

        // inside slice
        XCTAssertEqual(initial.z(3 ... 5), VoxelBounds(min: (0, 0, 3), max: (10, 10, 5)))
    }
}
