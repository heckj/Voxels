import Voxels
import XCTest

class MarchingCubesRendererTests: XCTestCase {
    public static func manhattanNeighbor1() -> VoxelHash<Float> {
        var voxels = VoxelHash<Float>(defaultVoxel: Float.greatestFiniteMagnitude)
        voxels.set(VoxelIndex(2, 2, 2), newValue: -1)

        voxels.set(VoxelIndex(1, 2, 2), newValue: -1)
        voxels.set(VoxelIndex(3, 2, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 1, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 3, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 2, 1), newValue: -1)
        voxels.set(VoxelIndex(2, 2, 3), newValue: -1)
        return voxels
    }

    func testCalculatedNormal() throws {
        let verts: [Vector] = [Vector(0, 0, 0), Vector(1, 0, 0), Vector(1, 1, 0)]
        let normalCalc: Vector = (verts[1] - verts[0]).cross(verts[2] - verts[1])
        XCTAssertEqual(normalCalc, Vector(0, 0, 1))
    }

    func testManhattanNeighborMeshSurface() throws {
        let voxels = Self.manhattanNeighbor1()

        let meshbuffer = MarchingCubesRenderer().render(voxels, scale: .init(), within: voxels.bounds.expand())

        let numberOfTriangles = meshbuffer.indices.count / 3
        XCTAssertEqual(56, numberOfTriangles)
    }

    func testSingleVoxelBlockMesh() throws {
        var voxels = VoxelHash<Float>()
        voxels.set(VoxelIndex(2, 2, 2), newValue: -1.0)

        let meshbuffer = MarchingCubesRenderer().render(voxels, scale: .init(), within: voxels.bounds.expand())

        let numberOfTriangles = meshbuffer.indices.count / 3
        XCTAssertEqual(8, numberOfTriangles)
    }
}
