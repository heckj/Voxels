import Voxels
import XCTest

class VoxelIndexTests: XCTestCase {
    func testIndexInit() throws {
        XCTAssertEqual(VoxelIndex(0, 0, 0), VoxelIndex())

        XCTAssertNotNil(VoxelIndex(0, 0, 0))
        XCTAssertNotNil(VoxelIndex(x: 0, y: 0, z: 0))

        XCTAssertNotNil(VoxelIndex(0, 0, 0))
        XCTAssertNotNil(VoxelIndex([0, 0, 0]))
        let xyz = [1, 1, 1]
        XCTAssertNotNil(VoxelIndex(xyz))
        let ijk = (2, 2, 2)
        XCTAssertNotNil(VoxelIndex(ijk))
    }

    func testConvenienceAdd() throws {
        let shiftedIndex = VoxelIndex().adding(1, 1, 1)
        XCTAssertEqual(shiftedIndex, VoxelIndex.one)

        let nextIndexUp = shiftedIndex.adding(y: 1)
        XCTAssertEqual(nextIndexUp, VoxelIndex(1, 2, 1))
    }

    func testIndexComparable() throws {
        XCTAssertTrue(VoxelIndex(0, 0, 0) < VoxelIndex(2, 2, 2))
        XCTAssertFalse(VoxelIndex(0, 0, 0) > VoxelIndex(2, 2, 2))
    }

    func testIndexEquatable() throws {
        XCTAssertTrue(VoxelIndex(0, 0, 0) != VoxelIndex(2, 2, 2))
        XCTAssertTrue(VoxelIndex(2, 2, 2) == VoxelIndex(2, 2, 2))
    }

    // MARK: Neighbors

    func testDistance() throws {
        XCTAssertEqual(VoxelIndex.manhattan_distance(from: VoxelIndex(0, 0, 0), to: VoxelIndex(0, 0, 1)), 1)

        XCTAssertEqual(VoxelIndex.manhattan_distance(from: VoxelIndex(0, 0, 0), to: VoxelIndex(0, 1, 1)), 2)

        XCTAssertEqual(VoxelIndex.manhattan_distance(from: VoxelIndex(0, 0, 0), to: VoxelIndex(1, 1, 1)), 3)
    }

    func testNeighborsOfArray() throws {
        let fiveByFive = VoxelArray<Int>(edge: 7, value: 1)

        let distanceZeroNeighbors = try VoxelIndex.neighbors(distance: 0, origin: VoxelIndex(3, 2, 1), voxels: fiveByFive)
        XCTAssertEqual(distanceZeroNeighbors.count, 1)

        // verify index in neighbor is index position from original voxel storage
        XCTAssertEqual(distanceZeroNeighbors.sorted().first, VoxelIndex(3, 2, 1))

        let distanceOneNeighbors = try VoxelIndex.neighbors(distance: 1, origin: VoxelIndex(1, 1, 1), voxels: fiveByFive)
        XCTAssertEqual(distanceOneNeighbors.count, 7)

        let distanceTwoNeighbors = try VoxelIndex.neighbors(distance: 2, origin: VoxelIndex(2, 2, 2), voxels: fiveByFive)
        XCTAssertEqual(distanceTwoNeighbors.count, 25)
    }

    func testNeighborsOfHash() throws {
        var fiveByFive = VoxelHash<Int>()

        // create cube in the middle
        for i in 1 ... 3 {
            for j in 1 ... 3 {
                for k in 1 ... 3 {
                    fiveByFive.set(VoxelIndex(i, j, k), newValue: 1)
                }
            }
        }
        XCTAssertEqual(fiveByFive.count, 27)

        let neighbors = try VoxelIndex.neighbors(distance: 0, origin: VoxelIndex(2, 2, 2), voxels: fiveByFive, strategy: .raw)
        XCTAssertEqual(neighbors.count, 1)
    }

    func testNeighbors1() throws {
        let index = VoxelIndex((12, 5, 1))
        let neighbors = index.manhattan_1_neighbors()
        XCTAssertEqual(neighbors.count, 6)
        for n in neighbors {
            XCTAssertEqual(VoxelIndex.manhattan_distance(from: index, to: n), 1)
        }
    }

    func testNeighbors2() throws {
        let index = VoxelIndex((2, 2, 2))
        let neighbors = index.manhattan_2_neighbors()
        XCTAssertEqual(neighbors.count, 24)
        for n in neighbors {
            let distance = VoxelIndex.manhattan_distance(from: index, to: n)
            // print("distance from \(index) to \(n) is \(distance)")
            XCTAssertTrue(distance <= 2)
        }
    }

    func testBuiltins() throws {
        XCTAssertEqual(VoxelIndex.one.x, 1)
        XCTAssertEqual(VoxelIndex.one.y, 1)
        XCTAssertEqual(VoxelIndex.one.z, 1)

        XCTAssertEqual(VoxelIndex.zero.x, 0)
        XCTAssertEqual(VoxelIndex.zero.y, 0)
        XCTAssertEqual(VoxelIndex.zero.z, 0)
    }

    func testDescription() throws {
        XCTAssertEqual("\(VoxelIndex.one)", "[1, 1, 1]")
    }

    func testIdentifiable() throws {
        XCTAssertEqual("\(VoxelIndex.one.id)", "[1, 1, 1]")
    }
}
