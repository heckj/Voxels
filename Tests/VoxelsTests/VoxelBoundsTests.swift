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

    func testVoxelBoundsEmptySequence() throws {
        XCTAssertEqual(VoxelBounds([]), .empty)
    }

    func testEmptyVoxelBoundsStride() throws {
        let emptyBounds = VoxelBounds.empty
        let index = try emptyBounds.linearize(emptyBounds.min)
        XCTAssertEqual(index, 0)
        XCTAssertEqual(emptyBounds.size, 1)
    }

    func testXOnlyBoundsStride() throws {
        let smallBounds = VoxelBounds(min: [0, 0, 0], max: [0, 0, 2])
        let index = try smallBounds.linearize(smallBounds.max)
        XCTAssertEqual(smallBounds.size, 3)
        XCTAssertEqual(index, 2)
        for j in 0 ..< smallBounds.size {
            let computedIndex = try smallBounds.delinearize(j)
            XCTAssertEqual(try smallBounds.linearize(computedIndex), j)
        }
    }

    func testYOnlyBoundsStride() throws {
        let smallBounds = VoxelBounds(min: [0, 0, 0], max: [0, 2, 0])
        let index = try smallBounds.linearize(smallBounds.max)
        XCTAssertEqual(smallBounds.size, 3)
        XCTAssertEqual(index, 2)
        for j in 0 ..< smallBounds.size {
            let computedIndex = try smallBounds.delinearize(j)
            XCTAssertEqual(try smallBounds.linearize(computedIndex), j)
        }
    }

    func testZOnlyBoundsStride() throws {
        let smallBounds = VoxelBounds(min: [0, 0, 0], max: [2, 0, 0])
        let index = try smallBounds.linearize(smallBounds.max)
        XCTAssertEqual(smallBounds.size, 3)
        XCTAssertEqual(index, 2)
        for j in 0 ..< smallBounds.size {
            let computedIndex = try smallBounds.delinearize(j)
            XCTAssertEqual(try smallBounds.linearize(computedIndex), j)
        }
    }

    func testSquareXYBoundsStride() throws {
        let smallBounds = VoxelBounds(min: [0, 0, 0], max: [2, 2, 0])
        let index = try smallBounds.linearize(smallBounds.max)
        XCTAssertEqual(smallBounds.size, 9)
        XCTAssertEqual(index, 8)
        for j in 0 ..< smallBounds.size {
            let computedIndex = try smallBounds.delinearize(j)
            // print("stride location \(j) -delinearize-> \(computedIndex)")
            let reversed = try smallBounds.linearize(computedIndex)
            // print("\(computedIndex) -linearize-> \(reversed)")
            XCTAssertEqual(reversed, j)
        }
    }

    func testSquareYZBoundsStride() throws {
        let smallBounds = VoxelBounds(min: [0, 0, 0], max: [0, 2, 2])
        let index = try smallBounds.linearize(smallBounds.max)
        XCTAssertEqual(smallBounds.size, 9)
        XCTAssertEqual(index, 8)
        for j in 0 ..< smallBounds.size {
            let computedIndex = try smallBounds.delinearize(j)
            XCTAssertEqual(try smallBounds.linearize(computedIndex), j)
        }
    }

    func testSquareXZBoundsStride() throws {
        let smallBounds = VoxelBounds(min: [0, 0, 0], max: [2, 0, 2])
        let index = try smallBounds.linearize(smallBounds.max)
        XCTAssertEqual(smallBounds.size, 9)
        XCTAssertEqual(index, 8)
        for j in 0 ..< smallBounds.size {
            let computedIndex = try smallBounds.delinearize(j)
            XCTAssertEqual(try smallBounds.linearize(computedIndex), j)
        }
    }

    func testCubeBoundsStride() throws {
        let smallBounds = VoxelBounds(min: [0, 0, 0], max: [2, 2, 2])
        let index = try smallBounds.linearize(smallBounds.max)
        XCTAssertEqual(smallBounds.size, 27)
        XCTAssertEqual(index, 26)
        for j in 0 ..< smallBounds.size {
            let computedIndex = try smallBounds.delinearize(j)
            // print("stride location \(j) -delinearize-> \(computedIndex)")
            let reversed = try smallBounds.linearize(computedIndex)
            // print("\(computedIndex) -linearize-> \(reversed)")
            XCTAssertEqual(reversed, j)
        }
    }

    func testVoxelBoundsSingleIndex() {
        let bounds = VoxelBounds(VoxelIndex(2, 2, 2))
        XCTAssertEqual(bounds.indices.count, 1)
    }

    func testVoxelBoundsTwoIndixes() {
        let bounds = VoxelBounds(min: VoxelIndex(2, 2, 2), max: VoxelIndex(3, 2, 2))
        XCTAssertEqual(bounds.size, 2)
        XCTAssertEqual(bounds.indices.count, 2)
    }
}
