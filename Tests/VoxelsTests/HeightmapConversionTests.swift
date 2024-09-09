@testable import Voxels
import XCTest

final class HeightmapConversionTests: XCTestCase {
    func testUnitCentroidValue() throws {
        // for mapping a heightmap into a Voxel set of centroid SDF values,
        // we need to know the 'unit height' equivalent of the centroid of a voxel.

        // for a maxHeight of 6 (Voxels 0...5)
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(0, max: 6), 0.08, accuracy: 0.01)
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(1, max: 6), 0.25, accuracy: 0.01)
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(2, max: 6), 0.41, accuracy: 0.01)
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(3, max: 6), 0.58, accuracy: 0.01)
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(4, max: 6), 0.75, accuracy: 0.01)
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(5, max: 6), 0.91, accuracy: 0.01)
        // stepping above the max height should result in > 1.0 values
        XCTAssertEqual(VoxelHash<Float>.unitCentroidValue(6, max: 6), 1.08, accuracy: 0.01)
    }

    func testAccessingFloors() throws {
        let unitFloatValues: [[Float]] = [
            [0.1, 0.2, 0.3, 0.4],
            [0.2, 0.3, 0.4, 0.5],
            [0.3, 0.4, 0.5, 0.6],
            [0.4, 0.3, 0.4, 0.5],
        ]

        XCTAssertEqual(unitFloatValues[0][0], 0.1)
        XCTAssertEqual(unitFloatValues[3][2], 0.4)
        // generally, unitFloatValues[z][x]

        XCTAssertEqual(VoxelHash<Float>.unitSurfaceIndexValue(x: 0, y: 0, heightmap: unitFloatValues, maxHeight: 10), 1)
        XCTAssertEqual(VoxelHash<Float>.unitSurfaceIndexValue(x: 1, y: 0, heightmap: unitFloatValues, maxHeight: 10), 2)
        XCTAssertEqual(VoxelHash<Float>.unitSurfaceIndexValue(x: 2, y: 0, heightmap: unitFloatValues, maxHeight: 10), 3)
        XCTAssertEqual(VoxelHash<Float>.unitSurfaceIndexValue(x: 3, y: 0, heightmap: unitFloatValues, maxHeight: 10), 4)
        // highest value in the map
        XCTAssertEqual(VoxelHash<Float>.unitSurfaceIndexValue(x: 3, y: 2, heightmap: unitFloatValues, maxHeight: 10), 6)
    }

    func testSizeOfHeightmapAwkward() throws {
        let unitFloatValues: [[Float]] = [
            [0.1, 0.2, 0.3, 0.4],
            [0.2, 0.4, 0.5],
            [0.3],
            [0.4, 0.3, 0.4, 0.5],
        ]
        let result = VoxelHash<Float>.sizeOfHeightmap(unitFloatValues)
        XCTAssertEqual(result.height, 4)
        XCTAssertEqual(result.width, 4)

        XCTAssertThrowsError(try VoxelHash<Float>.flattenAndCheck(unitFloatValues))
    }

    func testSizeOfHeightmap() throws {
        let unitFloatValues: [[Float]] = [
            [0.1, 0.2, 0.3, 0.4],
            [0.2, 0.3, 0.4, 0.5],
            [0.3, 0.4, 0.5, 0.6],
        ]
        let result = VoxelHash<Float>.sizeOfHeightmap(unitFloatValues)
        XCTAssertEqual(result.height, 3)
        XCTAssertEqual(result.width, 4)

        let flattened = try VoxelHash<Float>.flattenAndCheck(unitFloatValues)
        XCTAssertEqual(flattened.1, 4)
        XCTAssertEqual(flattened.0.count, 12)
    }

    func testTwoDIndexNeighborsFrom() throws {
        let neighborsCorner = VoxelHash<Float>.twoDIndexNeighborsFrom(x: 0, z: 0, widthCount: 3, heightCount: 3)
        XCTAssertEqual(neighborsCorner.count, 3)

        let neighborsMid = VoxelHash<Float>.twoDIndexNeighborsFrom(x: 1, z: 1, widthCount: 3, heightCount: 3)
        XCTAssertEqual(neighborsMid.count, 8)

        let neighborsSide = VoxelHash<Float>.twoDIndexNeighborsFrom(x: 1, z: 0, widthCount: 3, heightCount: 3)
        XCTAssertEqual(neighborsSide.count, 5)

        let neighborsFarCorner = VoxelHash<Float>.twoDIndexNeighborsFrom(x: 3, z: 2, widthCount: 4, heightCount: 3)
        XCTAssertEqual(neighborsFarCorner.count, 3)
    }

    func testPointDistanceToLine() throws {
        let p = SIMD3<Float>(0, 0, 0)
        let distance = VoxelHash<Float>.pointdistancetoline(p: p, x1: SIMD3<Float>(1, 1, 0), x2: SIMD3<Float>(1, -1, 0))
        XCTAssertEqual(distance, 1)

        XCTAssertEqual(VoxelHash<Float>.pointdistancetoline(p: p, x1: SIMD3<Float>(2, 0, 0), x2: SIMD3<Float>(0, 2, 0)), sqrt(2.0), accuracy: 0.01)
    }

    func testHeightMapToVoxel() throws {
        let unitFloatValues: [[Float]] = [
            [0.1, 0.2, 0.3, 0.4],
            [0.2, 0.3, 0.4, 0.5],
            [0.3, 0.4, 0.5, 0.6],
            [0.4, 0.3, 0.4, 0.2],
        ]
        let voxels = VoxelHash<Float>.heightmap(unitFloatValues, maxVoxelHeight: 10, scale: .init())
        XCTAssertEqual(voxels.count, 96)
        for voxelValue in voxels {
            XCTAssertTrue(!voxelValue.isNaN)
        }

        // voxels.dump()
    }

    func testTinyHeightMapToVoxel() throws {
        let unitFloatValues: [[Float]] = [
            [0.1, 0.1],
            [0.1, 0.5],
        ]
        let voxels = VoxelHash<Float>.heightmap(unitFloatValues, maxVoxelHeight: 5, scale: .init())
        XCTAssertEqual(voxels.count, 16)
        for voxelValue in voxels {
            XCTAssertTrue(!voxelValue.isNaN)
        }

        // voxels.dump()
    }

    func testSmallHeightMapToVoxel() throws {
        let unitFloatValues: [[Float]] = [
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.5, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.0],
        ]
        let voxels = VoxelHash<Float>.heightmap(unitFloatValues, maxVoxelHeight: 5, scale: .init())
        XCTAssertEqual(voxels.count, 79)
        for voxelValue in voxels {
            XCTAssertTrue(!voxelValue.isNaN)
        }

        // voxels.dump()
    }

    func test2DstrideToXY() throws {
        var result = VoxelHash<Float>.strideToXZ(5, width: 4)
        XCTAssertEqual(result.x, 1)
        XCTAssertEqual(result.z, 1)

        result = VoxelHash<Float>.strideToXZ(4, width: 4)
        XCTAssertEqual(result.x, 0)
        XCTAssertEqual(result.z, 1)

        result = VoxelHash<Float>.strideToXZ(3, width: 4)
        XCTAssertEqual(result.x, 3)
        XCTAssertEqual(result.z, 0)

        result = VoxelHash<Float>.strideToXZ(0, width: 4)
        XCTAssertEqual(result.x, 0)
        XCTAssertEqual(result.z, 0)
    }

    func test2DXYToStride() throws {
        XCTAssertEqual(VoxelHash<Float>.XZtoStride(x: 0, z: 0, width: 4), 0)
        XCTAssertEqual(VoxelHash<Float>.XZtoStride(x: 1, z: 0, width: 4), 1)
        XCTAssertEqual(VoxelHash<Float>.XZtoStride(x: 2, z: 0, width: 4), 2)
        XCTAssertEqual(VoxelHash<Float>.XZtoStride(x: 3, z: 0, width: 4), 3)
        XCTAssertEqual(VoxelHash<Float>.XZtoStride(x: 0, z: 1, width: 4), 4)
        XCTAssertEqual(VoxelHash<Float>.XZtoStride(x: 1, z: 1, width: 4), 5)
    }
}
