@testable import Voxels
import XCTest

class VoxelHashTests: XCTestCase {
    func testVoxelHashInitializer() throws {
        let voxels = VoxelHash<Int>()

        XCTAssertEqual(voxels.count, 0)
        XCTAssertNil(voxels[SIMD3<Int>(0, 0, 0)])
    }

    func testVoxelAccess() throws {
        var voxels = VoxelHash<Int>()
        voxels[SIMD3<Int>(0, 0, 0)] = 1
        voxels[SIMD3<Int>(1, 1, 1)] = 1

        XCTAssertEqual(voxels.count, 2)
        XCTAssertEqual(voxels[.zero], 1)
        XCTAssertNil(voxels[SIMD3<Int>(2, 2, 2)])
    }

    func testVoxelBounds() throws {
        var voxels = VoxelHash<Int>()
        voxels[SIMD3<Int>(0, 0, 0)] = 1
        voxels[SIMD3<Int>(1, 1, 1)] = 1

        let bounds = voxels.bounds
        XCTAssertEqual(bounds?.min, SIMD3<Int>(0, 0, 0))
        XCTAssertEqual(bounds?.max, SIMD3<Int>(1, 1, 1))
    }

    func testVoxelSequence() throws {
        var voxels = VoxelHash<Int>()
        voxels[SIMD3<Int>(0, 0, 0)] = 1
        voxels[SIMD3<Int>(1, 1, 1)] = 2

        let ones = voxels.filter { $0 == 1 }
        XCTAssertEqual(ones.count, 1)
    }
}
