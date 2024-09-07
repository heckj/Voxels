import Voxels
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
    }

    func testTwoDIndexNeighborsFrom() throws {
        let neighborsCorner = VoxelHash<Float>.twoDIndexNeighborsFrom(x: 0, y: 0, widthCount: 3, heightCount: 3)
        XCTAssertEqual(neighborsCorner.count, 4)

        let neighborsMid = VoxelHash<Float>.twoDIndexNeighborsFrom(x: 1, y: 1, widthCount: 3, heightCount: 3)
        XCTAssertEqual(neighborsMid.count, 9)

        let neighborsSide = VoxelHash<Float>.twoDIndexNeighborsFrom(x: 1, y: 0, widthCount: 3, heightCount: 3)
        XCTAssertEqual(neighborsSide.count, 6)
    }
}
