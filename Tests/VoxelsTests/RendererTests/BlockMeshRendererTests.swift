@testable import Voxels
import XCTest

class VoxelMeshRendererTests: XCTestCase {
    func testFastBlockMeshSurface() throws {
        var fiveByFive = VoxelHash<Int>(defaultVoxel: 0)

        // create cube in the middle
        for i in 1 ... 3 {
            for j in 1 ... 3 {
                for k in 1 ... 3 {
                    fiveByFive.set(VoxelIndex(i, j, k), newValue: 1)
                }
            }
        }

        let meshbuffer = BlockMeshRenderer().render(fiveByFive, scale: VoxelScale<Float>(), within: fiveByFive.bounds.expand(), surfaceOnly: true)
        let numberOfTriangles = meshbuffer.indices.count / 3
        // _6_ sides, with 9 faces in each, 2 triangles per face
        XCTAssertEqual(6 * 9 * 2, numberOfTriangles)
    }

    public static func manhattanNeighbor1() -> VoxelHash<Float> {
        var voxels = VoxelHash<Float>(defaultVoxel: Float.greatestFiniteMagnitude)
        voxels.set(VoxelIndex(2, 2, 2), newValue: -2)

        voxels.set(VoxelIndex(1, 2, 2), newValue: -1)
        voxels.set(VoxelIndex(3, 2, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 1, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 3, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 2, 1), newValue: -1)
        voxels.set(VoxelIndex(2, 2, 3), newValue: -1)
        return voxels
    }

    func testManhattanNeighborMeshSurface() throws {
        let voxels = Self.manhattanNeighbor1()
        let meshbuffer = BlockMeshRenderer().render(voxels, scale: .init(), within: voxels.bounds.expand(), surfaceOnly: true)
        let numberOfTriangles = meshbuffer.indices.count / 3
        // _6_ cubes, with 5 faces in each, 2 triangles per face
        XCTAssertEqual(6 * 5 * 2, numberOfTriangles)
    }

    func testManhattanNeighborMeshSurfaceWithinBounds() throws {
        let voxels = Self.manhattanNeighbor1()
        // taking a slice of Y index layer '2', only surface blocks
        let meshbuffer = BlockMeshRenderer().render(voxels,
                                                    scale: .init(),
                                                    within: VoxelBounds(min: VoxelIndex(0, 2, 0), max: VoxelIndex(4, 2, 4)), surfaceOnly: true)
        let numberOfTriangles = meshbuffer.indices.count / 3
        // _4_ cubes, with 5 faces in each, 2 triangles per face
        XCTAssertEqual(4 * 5 * 2, numberOfTriangles)
    }

    func testManhattanNeighborMeshSurfaceWithinBounds2() throws {
        let voxels = Self.manhattanNeighbor1()
        // taking a slice of Y index layer '3', only surface blocks
        let meshbuffer = BlockMeshRenderer().render(voxels,
                                                    scale: .init(),
                                                    within: VoxelBounds(min: VoxelIndex(0, 3, 0), max: VoxelIndex(4, 3, 4)),
                                                    surfaceOnly: true)
        let numberOfTriangles = meshbuffer.indices.count / 3
        // _1_ cubes, with 5 faces in each, 2 triangles per face
        XCTAssertEqual(1 * 5 * 2, numberOfTriangles)
    }

    func testManhattanNeighborMeshAllBlocks() throws {
        let voxels = Self.manhattanNeighbor1()
        let meshbuffer = BlockMeshRenderer().render(voxels, scale: .init(), within: voxels.bounds.expand())
        let numberOfTriangles = meshbuffer.indices.count / 3
        // _7_ cubes, with 6 faces in each, 2 triangles per face
        XCTAssertEqual(7 * 6 * 2, numberOfTriangles)
    }

    func testManhattanNeighborMeshWithinBounds() throws {
        let voxels = Self.manhattanNeighbor1()
        // taking a slice of Y index layer '2', only surface blocks
        let meshbuffer = BlockMeshRenderer().render(voxels,
                                                    scale: .init(),
                                                    within: VoxelBounds(min: VoxelIndex(0, 2, 0), max: VoxelIndex(4, 2, 4)))
        let numberOfTriangles = meshbuffer.indices.count / 3
        // _5_ cubes, with 6 faces in each, 2 triangles per face
        XCTAssertEqual(5 * 6 * 2, numberOfTriangles)
    }

    func testManhattanNeighborMeshWithinBounds2() throws {
        let voxels = Self.manhattanNeighbor1()
        // taking a slice of Y index layer '3', only surface blocks
        let meshbuffer = BlockMeshRenderer().render(voxels,
                                                    scale: .init(),
                                                    within: VoxelBounds(min: VoxelIndex(0, 3, 0), max: VoxelIndex(4, 3, 4)))
        let numberOfTriangles = meshbuffer.indices.count / 3
        // _1_ cubes, with 6 faces in each, 2 triangles per face
        XCTAssertEqual(1 * 6 * 2, numberOfTriangles)
    }

    func testManhattanNeighborsByLayer() throws {
        let voxels = Self.manhattanNeighbor1()
        // taking a slice of Y index layer '3', only surface blocks
        let collectionOfBuffers = BlockMeshRenderer.fastBlockMeshByLayers(voxels, scale: .init())

        XCTAssertEqual(collectionOfBuffers.count, 3)

        let top = try XCTUnwrap(collectionOfBuffers[3])
        // _1_ cubes, with 6 faces in each, 2 triangles per face
        XCTAssertEqual(1 * 6 * 2, top.indices.count / 3)

        let middle = try XCTUnwrap(collectionOfBuffers[2])
        // _5_ cubes, with 6 faces in each, 2 triangles per face
        XCTAssertEqual(5 * 6 * 2, middle.indices.count / 3)

        let bottom = try XCTUnwrap(collectionOfBuffers[1])
        // _1_ cubes, with 6 faces in each, 2 triangles per face
        XCTAssertEqual(1 * 6 * 2, bottom.indices.count / 3)

        XCTAssertNil(collectionOfBuffers[0])
    }

    func testSingleVoxelBlockMesh() throws {
        var voxels = VoxelHash<Float>()
        voxels.set(VoxelIndex(2, 2, 2), newValue: -1.0)
        let meshbuffer = BlockMeshRenderer().render(voxels, scale: .init(), within: voxels.bounds.expand())

        let numberOfTriangles = meshbuffer.indices.count / 3
        // _1_ cubes, with 6 faces in each, 2 triangles per face
        XCTAssertEqual(1 * 6 * 2, numberOfTriangles)
    }

    func testSingleVoxelBlockMeshSurfaceFaces() throws {
        var voxels = VoxelHash<Float>(defaultVoxel: Float.greatestFiniteMagnitude)
        voxels.set(VoxelIndex(2, 2, 2), newValue: -1.0)
        let meshbuffer = BlockMeshRenderer().render(voxels, scale: .init(), within: voxels.bounds.expand(), surfaceOnly: true)

        let numberOfTriangles = meshbuffer.indices.count / 3
        // _1_ cubes, with 6 faces in each, 2 triangles per face
        XCTAssertEqual(1 * 6 * 2, numberOfTriangles)
    }

    func testBlockMeshRendererFilter() throws {
        let voxels = Self.manhattanNeighbor1()
        let meshbuffer = BlockMeshRenderer().render(voxels, scale: .init(), within: voxels.bounds.expand()) { voxelValue in
            voxelValue < -1.0
        }

        let numberOfTriangles = meshbuffer.indices.count / 3
        // _1_ cubes, with 6 faces in each, 2 triangles per face
        XCTAssertEqual(1 * 6 * 2, numberOfTriangles)

        let meshbuffer2 = BlockMeshRenderer().render(voxels, scale: .init(), within: voxels.bounds.expand()) { _ in
            true
        }

        let numberOfTriangles2 = meshbuffer2.indices.count / 3
        // _1_ cubes, with 6 faces in each, 2 triangles per face
        XCTAssertEqual(7 * 6 * 2, numberOfTriangles2)
    }
}
