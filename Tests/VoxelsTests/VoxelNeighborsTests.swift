@testable import Voxels
import XCTest

class VoxelNeighborsTests: XCTestCase {
    func testDistance() throws {
        XCTAssertEqual(Neighbors<Any>.manhattan_distance(from: SIMD3<Int>(0, 0, 0), to: SIMD3<Int>(0, 0, 1)), 1)

        XCTAssertEqual(Neighbors<Any>.manhattan_distance(from: SIMD3<Int>(0, 0, 0), to: SIMD3<Int>(0, 1, 1)), 2)

        XCTAssertEqual(Neighbors<Any>.manhattan_distance(from: SIMD3<Int>(0, 0, 0), to: SIMD3<Int>(1, 1, 1)), 3)
    }

    func testRetrieveNeighbors() throws {
        let fiveByFive = VoxelArray<Int>(edge: 7, value: 1)

        let distanceZeroNeighbors = Neighbors(distance: 0, origin: SIMD3<Int>(3, 2, 1), voxels: fiveByFive)
        XCTAssertEqual(distanceZeroNeighbors._storage.count, 1)

        // verify index in neighbor is index position from original voxel storage
        XCTAssertEqual(distanceZeroNeighbors._storage._contents.keys.first, SIMD3<Int>(3, 2, 1))

        let distanceOneNeighbors = Neighbors(distance: 1, origin: SIMD3<Int>(1, 1, 1), voxels: fiveByFive)
        XCTAssertEqual(distanceOneNeighbors._storage.count, 7)

//        for (k,_) in distanceOneNeighbors._storage._contents {
//            print("index: \(k)")
//        }

        let distanceTwoNeighbors = Neighbors(distance: 2, origin: SIMD3<Int>(2, 2, 2), voxels: fiveByFive)
        XCTAssertEqual(distanceTwoNeighbors._storage.count, 25)
    }
}
