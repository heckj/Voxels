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

    func testVoxelAccessInt() throws {
        var voxels = VoxelHash<Int>()
        voxels[SIMD3<Int>(0, 0, 0)] = 1
        voxels[SIMD3<Int>(1, 1, 1)] = 1

        XCTAssertEqual(voxels.count, 2)
        XCTAssertEqual(voxels.value(x: 0, y: 0, z: 0), 1)
        XCTAssertNil(voxels.value(x: 2, y: 2, z: 2))
    }

    func testVoxelRemoval() throws {
        var voxels = VoxelHash<Int>()
        voxels[SIMD3<Int>(0, 0, 0)] = 1
        voxels[SIMD3<Int>(1, 1, 1)] = 1

        XCTAssertEqual(voxels.count, 2)
        voxels[SIMD3<Int>(1, 1, 1)] = nil
        XCTAssertEqual(voxels.count, 1)
    }

    func testVoxelBounds() throws {
        var voxels = VoxelHash<Int>()
        voxels[SIMD3<Int>(0, 0, 0)] = 1
        voxels[SIMD3<Int>(1, 1, 1)] = 1

        let bounds = voxels.bounds
        XCTAssertEqual(bounds?.min, SIMD3<Int>(0, 0, 0))
        XCTAssertEqual(bounds?.max, SIMD3<Int>(1, 1, 1))
    }

    func testNilVoxelBounds() throws {
        let voxels = VoxelHash<Int>()
        XCTAssertNil(voxels.bounds)
    }

    func testSingularVoxelBounds() throws {
        var voxels = VoxelHash<Int>()
        voxels[SIMD3<Int>(0, 0, 0)] = 1

        let bounds = voxels.bounds
        XCTAssertEqual(bounds?.min, SIMD3<Int>(0, 0, 0))
        XCTAssertEqual(bounds?.max, SIMD3<Int>(0, 0, 0))
    }

    func testVoxelSequence() throws {
        var voxels = VoxelHash<Int>()
        voxels[SIMD3<Int>(0, 0, 0)] = 1
        voxels[SIMD3<Int>(1, 1, 1)] = 2

        let ones = voxels.filter { $0 == 1 }
        XCTAssertEqual(ones.count, 1)
    }
}
