@testable import Voxels
import XCTest

class VoxelAccessibleTests: XCTestCase {
    func testVoxelHashInitializer() throws {
        let voxels = SampleMeshData.manhattanNeighbor1()

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
