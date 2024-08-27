import Voxels
import XCTest

class VoxelMeshRendererTests: XCTestCase {
    func testFastBlockMeshSurface() throws {
        var fiveByFive = VoxelHash<Int>()

        // create cube in the middle
        for i in 1 ... 3 {
            for j in 1 ... 3 {
                for k in 1 ... 3 {
                    fiveByFive.set(VoxelIndex(i, j, k), newValue: 1)
                }
            }
        }

        let meshbuffer = VoxelMeshRenderer.fastBlockMesh(fiveByFive, scale: VoxelScale<Float>())
        let numberOfTriangles = meshbuffer.indices.count / 3
        // _6_ sides, with 9 faces in each, 2 triangles per face
        XCTAssertEqual(6 * 9 * 2, numberOfTriangles)
    }
}
