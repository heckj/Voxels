@testable import Voxels
import XCTest

class VoxelAccessibleTests: XCTestCase {
    public static func manhattanNeighbor1() -> VoxelHash<Float> {
        var voxels = VoxelHash<Float>()
        voxels.set(VoxelIndex(2, 2, 2), newValue: -1)

        voxels.set(VoxelIndex(1, 2, 2), newValue: -1)
        voxels.set(VoxelIndex(3, 2, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 1, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 3, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 2, 1), newValue: -1)
        voxels.set(VoxelIndex(2, 2, 3), newValue: -1)
        return voxels
    }

    func testVoxelHashInitializer() throws {
        let voxels = Self.manhattanNeighbor1()

        XCTAssertEqual(voxels.count, 7)
        let indices = Array(voxels.indices)
        XCTAssertEqual(indices.count, 27)

        var count = 0
        for i: VoxelIndex in voxels.indices {
            if try voxels.isSurface(i) {
                count += 1
            }
        }
        XCTAssertEqual(count, 6)
    }
}
