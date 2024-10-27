@testable import Voxels
import XCTest

class VoxelAccessibleTests: XCTestCase {
    func testVoxelHashInitializer() throws {
        let voxels = SampleMeshData.manhattanNeighbor1()

        XCTAssertEqual(voxels.count, 7)
        XCTAssertEqual(voxels.bounds.count, 27)

        var count = 0
        for i: VoxelIndex in voxels.bounds {
            if voxels.isSurface(i) {
                count += 1
            }
        }
        XCTAssertEqual(count, 6)
    }
}
