@testable import Voxels
import XCTest

class VoxelBoundsTests: XCTestCase {
    func testVoxelBoundsInitFromSequence() throws {
        let seq = [VoxelIndex(0, 0, 0), VoxelIndex(1, 1, 1), VoxelIndex(2, 2, 2), VoxelIndex(0, 1, 2)]
        let bounds = try XCTUnwrap(VoxelBounds(seq))
        XCTAssertEqual(bounds.min, VoxelIndex(0, 0, 0))
        XCTAssertEqual(bounds.max, VoxelIndex(2, 2, 2))
    }

    func testConvenienceInitializer() throws {
        let bounds = VoxelBounds(min: (0, 0, 0), max: (2, 2, 2))
        XCTAssertEqual(bounds, VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(2, 2, 2)))
        XCTAssertEqual(bounds, VoxelBounds(min: [0, 0, 0], max: [2, 2, 2]))
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
            XCTAssertTrue(smallBounds.contains(computedIndex))
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
            XCTAssertTrue(smallBounds.contains(computedIndex))
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
            XCTAssertTrue(smallBounds.contains(computedIndex))
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
            XCTAssertTrue(smallBounds.contains(computedIndex))
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
            XCTAssertTrue(smallBounds.contains(computedIndex))
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
            XCTAssertTrue(smallBounds.contains(computedIndex))
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
            XCTAssertTrue(smallBounds.contains(computedIndex))

            let reversed = try smallBounds.linearize(computedIndex)
            // print("\(computedIndex) -linearize-> \(reversed)")
            XCTAssertEqual(reversed, j)
        }
    }

    func test3DBoxBoundsStride() throws {
        let smallBounds = VoxelBounds(min: [0, 0, 0], max: [1, 2, 3])
        let index = try smallBounds.linearize(smallBounds.max)
        XCTAssertEqual(smallBounds.size, 2 * 3 * 4) // 24
        XCTAssertEqual(index, (2 * 3 * 4) - 1) // 23
        for j in 0 ..< smallBounds.size {
            let computedIndex = try smallBounds.delinearize(j)
            print("stride location \(j) -delinearize-> \(computedIndex)")
            XCTAssertTrue(smallBounds.contains(computedIndex))

            let reversed = try smallBounds.linearize(computedIndex)
            print("\(computedIndex) -linearize-> \(reversed)")
            XCTAssertEqual(reversed, j)
        }
    }

    func testVoxelBoundsSingleIndex() {
        let bounds = VoxelBounds(VoxelIndex(2, 2, 2))
        XCTAssertEqual(bounds.indices.count, 1)
        XCTAssertEqual(bounds[0], VoxelIndex(2, 2, 2))
    }

    func testVoxelBoundsTwoIndices() {
        let bounds = VoxelBounds(min: VoxelIndex(2, 2, 2), max: VoxelIndex(3, 2, 2))
        XCTAssertEqual(bounds.size, 2)
        XCTAssertEqual(bounds.indices.count, 2)
        for idx in bounds {
            XCTAssertTrue(bounds.contains(idx))
        }
    }

    func testVoxelBoundsIndicesWithinBounds() {
        let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(4, 1, 8))

        XCTAssertEqual(bounds.indices.count, 2 * 5 * 9)
        for idx in bounds {
            XCTAssertTrue(bounds.contains(idx))
        }
    }

    func testVoxelBoundsInset() {
        let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(4, 1, 8))

        XCTAssertEqual(bounds.insetQuadrant().min, bounds.min)
        XCTAssertEqual(bounds.insetQuadrant().max, VoxelIndex(3, 0, 7))
        XCTAssertTrue(bounds.contains(bounds.insetQuadrant().min))
        XCTAssertTrue(bounds.contains(bounds.insetQuadrant().max))
    }

    func testVoxelBoundsInsetByValue() {
        let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(124, 12, 18))

        let insetBounds = bounds.insetQuadrant(3)
        XCTAssertEqual(insetBounds.min, VoxelIndex(0, 0, 0))
        XCTAssertEqual(insetBounds.max, VoxelIndex(121, 9, 15))
    }

    func testVoxelBoundsInsetEdgeCase() {
        let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(4, 1, 8))

        XCTAssertTrue(bounds.contains(bounds.insetQuadrant().insetQuadrant()))

        let squarebounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(2, 2, 2))
        let shrunkToZero = squarebounds.insetQuadrant().insetQuadrant()
        XCTAssertEqual(shrunkToZero.max, shrunkToZero.min)
        // verify doesn't shrink or callapse any further
        XCTAssertEqual(shrunkToZero, shrunkToZero.insetQuadrant())
    }

    func testVoxelBoundsExpand() {
        let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(4, 1, 8))
        let expanded = bounds.expand()
        XCTAssertTrue(expanded.contains(bounds))

        XCTAssertEqual(expanded.max, VoxelIndex(5, 2, 9))
        XCTAssertEqual(expanded.min, VoxelIndex(-1, -1, -1))
    }

    func testVoxelBoundsExpandFromOne() {
        let bounds = VoxelBounds(.one)
        let expanded = bounds.expand()
        XCTAssertTrue(expanded.contains(bounds))

        XCTAssertEqual(expanded.max, VoxelIndex(2, 2, 2))
        XCTAssertEqual(expanded.min, VoxelIndex(0, 0, 0))
    }

    func testVoxelBoundsExpandByValue() {
        let bounds = VoxelBounds(.one)
        let expanded = bounds.expand(3)
        XCTAssertTrue(expanded.contains(bounds))

        XCTAssertEqual(expanded.max, VoxelIndex(4, 4, 4))
        XCTAssertEqual(expanded.min, VoxelIndex(-2, -2, -2))
    }

    func testDescription() throws {
        let bounds = VoxelBounds(.zero)
        let expanded = bounds.expand(2)

        XCTAssertEqual("\(bounds)", "[0, 0, 0]...[0, 0, 0]")
        XCTAssertEqual("\(expanded)", "[-2, -2, -2]...[2, 2, 2]")
    }
}
