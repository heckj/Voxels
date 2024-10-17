@testable import Voxels
import XCTest

class VoxelArrayTests: XCTestCase {
    func testVoxelArrayInitializer() throws {
        let v = VoxelArray<Int>(edge: 3, value: 1)

        // internal access
        XCTAssertEqual(v._contents.count, 27)
        for internalValue in v._contents {
            XCTAssertEqual(internalValue, 1)
        }

        // external access
        XCTAssertEqual(try v.value(VoxelIndex(x: 0, y: 0, z: 0)), 1)
        XCTAssertEqual(try v.value(VoxelIndex(x: 1, y: 1, z: 1)), 1)
        XCTAssertEqual(try v.value(VoxelIndex(x: 2, y: 2, z: 2)), 1)

        XCTAssertEqual(v.bounds.size, 27)
    }

    func testVoxelArraySequence() throws {
        var voxels = VoxelArray<Int>(edge: 3, value: 1)
        try voxels.set(VoxelIndex(1, 1, 1), newValue: 2)

        let ones = voxels.filter { $0 == 1 }
        XCTAssertEqual(ones.count, 26)

        let twos = voxels.filter { $0 == 2 }
        XCTAssertEqual(twos.count, 1)
    }

    func testVoxelOutOfBoundsAccess() throws {
        let voxels = VoxelArray<Int>(edge: 3, value: 1)
        XCTAssertThrowsError(try voxels.value(VoxelIndex(x: -1, y: 0, z: 0)))

        XCTAssertThrowsError(try voxels.value(VoxelIndex(x: 2, y: 2, z: 3)))
    }

    func testApplyingVoxelUpdate() throws {
        let index = VoxelIndex(0, 1, 1)
        var voxels = VoxelArray<Int>(edge: 3, value: 1)

        let update = VoxelUpdate(index: index, value: 5)
        try voxels.updating(with: [update])

        XCTAssertEqual(voxels[index], 5)
    }

    func testApplyingVoxelUpdateFromHash() throws {
        let index = VoxelIndex(0, 1, 1)
        var voxels = VoxelArray<Int>(edge: 3, value: 1)

        var updateSet = VoxelHash<Int>()
        updateSet[index] = 5

        try voxels.updating(with: updateSet)

        XCTAssertEqual(voxels[index], 5)
    }
}
