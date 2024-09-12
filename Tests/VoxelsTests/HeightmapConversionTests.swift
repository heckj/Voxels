import Heightmap
@testable import Voxels
import XCTest

final class HeightmapConversionTests: XCTestCase {
    func testUnitCentroidValue() throws {
        // for mapping a heightmap into a Voxel set of centroid SDF values,
        // we need to know the 'unit height' equivalent of the centroid of a voxel.

        // for a maxHeight of 6 (Voxels 0...5)
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(0, maxHeight: 6), 0.0, accuracy: 0.01)
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(1, maxHeight: 6), 0.2, accuracy: 0.01)
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(2, maxHeight: 6), 0.4, accuracy: 0.01)
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(3, maxHeight: 6), 0.6, accuracy: 0.01)
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(4, maxHeight: 6), 0.8, accuracy: 0.01)
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(5, maxHeight: 6), 1.0, accuracy: 0.01)
        // stepping above the max height should result in > 1.0 values
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(6, maxHeight: 6), 1.2, accuracy: 0.01)
    }

    func testAccessingFloors() throws {
        let unitFloatValues: [[Float]] = [
            [0.1, 0.2, 0.3, 0.4],
            [0.2, 0.3, 0.4, 0.5],
            [0.3, 0.4, 0.5, 0.6],
            [0.4, 0.3, 0.4, 0.5],
        ]
        let heightmap = Heightmap(Array(unitFloatValues.joined()), width: 4)
        XCTAssertEqual(unitFloatValues[0][0], 0.1)
        XCTAssertEqual(heightmap[0, 0], 0.1)

        // note the inversion of lookup when switching from a nested array to Heightmap...
        XCTAssertEqual(unitFloatValues[2][3], 0.6)
        XCTAssertEqual(heightmap[3, 2], 0.6)

        XCTAssertEqual(VoxelHash<Float>.unitSurfaceIndexValue(XZIndex(x: 0, z: 0), heightmap: heightmap, maxHeight: 10), 0)
        XCTAssertEqual(VoxelHash<Float>.unitSurfaceIndexValue(XZIndex(x: 1, z: 0), heightmap: heightmap, maxHeight: 10), 1)
        XCTAssertEqual(VoxelHash<Float>.unitSurfaceIndexValue(XZIndex(x: 2, z: 0), heightmap: heightmap, maxHeight: 10), 2)
        XCTAssertEqual(VoxelHash<Float>.unitSurfaceIndexValue(XZIndex(x: 3, z: 0), heightmap: heightmap, maxHeight: 10), 3)
        // highest value in the map
        XCTAssertEqual(VoxelHash<Float>.unitSurfaceIndexValue(XZIndex(x: 3, z: 2), heightmap: heightmap, maxHeight: 10), 5)
    }

    func testTwoDIndexNeighborsFrom() throws {
        let neighborsCorner = VoxelHash<Float>.twoDIndexNeighborsFrom(position: XZIndex(x: 0, z: 0), widthCount: 3, depthCount: 3)
        XCTAssertEqual(neighborsCorner.count, 3)

        let neighborsMid = VoxelHash<Float>.twoDIndexNeighborsFrom(position: XZIndex(x: 1, z: 1), widthCount: 3, depthCount: 3)
        XCTAssertEqual(neighborsMid.count, 8)

        let neighborsSide = VoxelHash<Float>.twoDIndexNeighborsFrom(position: XZIndex(x: 1, z: 0), widthCount: 3, depthCount: 3)
        XCTAssertEqual(neighborsSide.count, 5)

        let neighborsFarCorner = VoxelHash<Float>.twoDIndexNeighborsFrom(position: XZIndex(x: 3, z: 2), widthCount: 4, depthCount: 3)
        XCTAssertEqual(neighborsFarCorner.count, 3)
    }

    func testPointDistanceToLine() throws {
        let p = SIMD3<Float>(0, 0, 0)
        let distance = VoxelHash<Float>.distanceFromPointToLine(p: p, x1: SIMD3<Float>(1, 1, 0), x2: SIMD3<Float>(1, -1, 0))
        XCTAssertEqual(distance, 1)

        XCTAssertEqual(VoxelHash<Float>.distanceFromPointToLine(p: p, x1: SIMD3<Float>(2, 0, 0), x2: SIMD3<Float>(0, 2, 0)), sqrt(2.0), accuracy: 0.01)
    }

    func testHeightMapToVoxel() throws {
        let unitFloatValues: [[Float]] = [
            [0.1, 0.2, 0.3, 0.4],
            [0.2, 0.3, 0.4, 0.5],
            [0.3, 0.4, 0.5, 0.6],
            [0.4, 0.3, 0.4, 0.2],
        ]
        let heightmap = Heightmap(Array(unitFloatValues.joined()), width: 4)
        let voxels = VoxelHash<Float>.heightmap(heightmap, maxVoxelHeight: 10)
        XCTAssertEqual(voxels.count, 93)
        for voxelValue in voxels {
            XCTAssertTrue(!voxelValue.isNaN)
        }

        XCTAssertEqual(voxels.bounds.max.y, 10)
        // voxels.dump()

        // FIXME: REVERSING IS NOT WORKING
        // let dumpedHeights = voxels.heightmap()
        // XCTAssertEqual([0.1, 0.2, 0.3, 0.4, 0.2, 0.3, 0.4, 0.5, 0.3, 0.4, 0.5, 0.6, 0.4, 0.3, 0.4, 0.2], dumpedHeights)
    }

    func testTinyHeightMapToVoxel() throws {
        let unitFloatValues: [[Float]] = [
            [0.1, 0.1],
            [0.1, 0.5],
        ]
        let heightmap = Heightmap(Array(unitFloatValues.joined()), width: 2)
        let voxels = VoxelHash<Float>.heightmap(heightmap, maxVoxelHeight: 5)
        XCTAssertEqual(voxels.count, 16)
        XCTAssertEqual(voxels.bounds.max.y, 5)
        for voxelValue in voxels {
            XCTAssertTrue(!voxelValue.isNaN)
        }

        let dumpedHeights = voxels.heightmap()
        XCTAssertEqual([0.1, 0.1, 0.1, 0.5], dumpedHeights.contents)
    }

    func testSmallHeightMapToVoxel() throws {
        let unitFloatValues: [[Float]] = [
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.5, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.0],
        ]
        let heightmap = Heightmap(Array(unitFloatValues.joined()), width: 5)
        let voxels = VoxelHash<Float>.heightmap(heightmap, maxVoxelHeight: 5)
        XCTAssertEqual(voxels.count, 99)
        for voxelValue in voxels {
            XCTAssertTrue(!voxelValue.isNaN)
        }

        // voxels.dump()
    }

    func test2DstrideToXY() throws {
        var result = XZIndex.strideToXZ(5, width: 4)
        XCTAssertEqual(result.x, 1)
        XCTAssertEqual(result.z, 1)

        result = XZIndex.strideToXZ(4, width: 4)
        XCTAssertEqual(result.x, 0)
        XCTAssertEqual(result.z, 1)

        result = XZIndex.strideToXZ(3, width: 4)
        XCTAssertEqual(result.x, 3)
        XCTAssertEqual(result.z, 0)

        result = XZIndex.strideToXZ(0, width: 4)
        XCTAssertEqual(result.x, 0)
        XCTAssertEqual(result.z, 0)
    }

    func test2DXYToStride() throws {
        XCTAssertEqual(XZIndex.XZtoStride(x: 0, z: 0, width: 4), 0)
        XCTAssertEqual(XZIndex.XZtoStride(x: 1, z: 0, width: 4), 1)
        XCTAssertEqual(XZIndex.XZtoStride(x: 2, z: 0, width: 4), 2)
        XCTAssertEqual(XZIndex.XZtoStride(x: 3, z: 0, width: 4), 3)
        XCTAssertEqual(XZIndex.XZtoStride(x: 0, z: 1, width: 4), 4)
        XCTAssertEqual(XZIndex.XZtoStride(x: 1, z: 1, width: 4), 5)
    }
}
