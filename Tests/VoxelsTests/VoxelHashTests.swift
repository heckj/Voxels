@testable import Voxels
import XCTest

class VoxelHashTests: XCTestCase {
    func testVoxelHashInitializer() throws {
        let voxels = VoxelHash<Int>()

        XCTAssertEqual(voxels.count, 0)
        XCTAssertNil(voxels.value(VoxelIndex(0, 0, 0)))
    }

    func testVoxelHashInitializerDefault() throws {
        let voxels = VoxelHash<Int>(defaultVoxel: Int.max)

        XCTAssertEqual(voxels.count, 0)

        XCTAssertEqual(voxels.value(VoxelIndex(2, 2, 2)), Int.max)
    }

    func testVoxelAccess() throws {
        var voxels = VoxelHash<Int>()
        voxels.set(VoxelIndex(0, 0, 0), newValue: 1)
        voxels.set(VoxelIndex(1, 1, 1), newValue: 1)

        XCTAssertEqual(voxels.count, 2)
        XCTAssertNil(voxels.value(VoxelIndex(2, 2, 2)))
        XCTAssertEqual(voxels.value(VoxelIndex(0, 0, 0)), 1)
    }

    func testVoxelRemoval() throws {
        var voxels = VoxelHash<Int>()
        voxels.set(VoxelIndex(0, 0, 0), newValue: 1)
        voxels.set(VoxelIndex(1, 1, 1), newValue: 1)

        XCTAssertEqual(voxels.count, 2)
        voxels.set(VoxelIndex(1, 1, 1), newValue: nil)
        XCTAssertEqual(voxels.count, 1)
    }

    func testVoxelBounds() throws {
        var voxels = VoxelHash<Int>()
        voxels.set(VoxelIndex(0, 0, 0), newValue: 1)
        voxels.set(VoxelIndex(1, 1, 1), newValue: 1)

        let bounds = voxels.bounds
        XCTAssertEqual(bounds.min, VoxelIndex(0, 0, 0))
        XCTAssertEqual(bounds.max, VoxelIndex(1, 1, 1))
    }

    func testEmptyVoxelBounds() throws {
        let voxels = VoxelHash<Int>()
        XCTAssertEqual(voxels.bounds, .empty)
    }

    func testSingularVoxelBounds() throws {
        var voxels = VoxelHash<Int>()
        voxels.set(VoxelIndex(1, 1, 1), newValue: 1)

        XCTAssertEqual(voxels.bounds.min, VoxelIndex(1, 1, 1))
        XCTAssertEqual(voxels.bounds.max, VoxelIndex(1, 1, 1))
    }

    func testSingularVoxelBoundsExpansion() throws {
        var voxels = VoxelHash<Int>()
        voxels.set(VoxelIndex(1, 1, 1), newValue: 1)

        XCTAssertEqual(voxels.bounds.min, VoxelIndex(1, 1, 1))
        XCTAssertEqual(voxels.bounds.max, VoxelIndex(1, 1, 1))

        voxels.set(VoxelIndex(2, 3, 4), newValue: 1)
        voxels.set(VoxelIndex(4, 3, 2), newValue: 1)
        voxels.set(VoxelIndex(2, 4, 3), newValue: 1)
        XCTAssertEqual(voxels.count, 4)
        XCTAssertEqual(voxels.bounds.min, VoxelIndex(1, 1, 1))
        XCTAssertEqual(voxels.bounds.max, VoxelIndex(4, 4, 4))
    }

    func testVoxelSequenceIterator() throws {
        var voxels = VoxelHash<Int>()
        voxels.set(VoxelIndex(0, 0, 0), newValue: 1)
        voxels.set(VoxelIndex(1, 1, 1), newValue: 2)

        var iterator = voxels.makeIterator()
        XCTAssertNotNil(iterator.next())
        XCTAssertNotNil(iterator.next())
        XCTAssertNil(iterator.next())
    }

    func testVoxelSequence() throws {
        var voxels = VoxelHash<Int>()
        voxels.set(VoxelIndex(0, 0, 0), newValue: 1)
        voxels.set(VoxelIndex(1, 1, 1), newValue: 2)

        // issue in filter with Collection iteration
        let ones = voxels.filter { $0 == 1 }
        XCTAssertEqual(ones.count, 1)
    }

    func testVoxelUpdateFromHash() throws {
        var voxels = VoxelHash<Int>()
        voxels.set(VoxelIndex(0, 0, 0), newValue: 1)
        voxels.set(VoxelIndex(1, 1, 1), newValue: 2)

        let updates = voxels.updates()
        XCTAssertEqual(updates.count, 2)
        XCTAssertEqual(updates[1].index, VoxelIndex(1, 1, 1))
        XCTAssertEqual(updates[1].value, 2)
    }

    func testApplyingVoxelUpdate() throws {
        let update = VoxelUpdate(index: VoxelIndex(0, 1, 1), value: 5)
        var voxels = VoxelHash<Int>()
        voxels.set(VoxelIndex(0, 0, 0), newValue: 1)
        voxels.set(VoxelIndex(1, 1, 1), newValue: 2)

        voxels.updating(with: [update])
        XCTAssertEqual(voxels.count, 3)
    }
}
