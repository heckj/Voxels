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

        let meshbuffer = VoxelMeshRenderer.fastBlockMeshSurfaceFaces(fiveByFive, scale: VoxelScale<Float>())
        let numberOfTriangles = meshbuffer.indices.count / 3
        // _6_ sides, with 9 faces in each, 2 triangles per face
        XCTAssertEqual(6 * 9 * 2, numberOfTriangles)
    }

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

    func testManhattanNeighborMesh() throws {
        let voxels = Self.manhattanNeighbor1()
        let meshbuffer = VoxelMeshRenderer.fastBlockMeshSurfaceFaces(voxels, scale: .init())
        let numberOfTriangles = meshbuffer.indices.count / 3
        // _6_ cubes, with 5 faces in each, 2 triangles per face
        XCTAssertEqual(6 * 5 * 2, numberOfTriangles)
    }
}
