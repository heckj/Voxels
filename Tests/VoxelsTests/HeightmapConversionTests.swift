import Heightmap
@testable import Voxels
import XCTest

final class HeightmapConversionTests: XCTestCase {
    func testUnitCentroidValue() throws {
        // for mapping a heightmap into a Voxel set of centroid SDF values,
        // we need to know the 'unit height' equivalent of the centroid of a voxel.

        // for a maxHeight of 6 (Voxels 0...5)
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(0, maxHeight: 6), 0.0, accuracy: 0.01)
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(1, maxHeight: 6), 0.2, accuracy: 0.01)
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(2, maxHeight: 6), 0.4, accuracy: 0.01)
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(3, maxHeight: 6), 0.6, accuracy: 0.01)
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(4, maxHeight: 6), 0.8, accuracy: 0.01)
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(5, maxHeight: 6), 1.0, accuracy: 0.01)
        // stepping above the max height should result in > 1.0 values
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(6, maxHeight: 6), 1.2, accuracy: 0.01)
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

        XCTAssertEqual(HeightmapConverter.indexOfSurface(XZIndex(x: 0, z: 0), heightmap: heightmap, maxHeight: 10), 0)
        XCTAssertEqual(HeightmapConverter.indexOfSurface(XZIndex(x: 1, z: 0), heightmap: heightmap, maxHeight: 10), 1)
        XCTAssertEqual(HeightmapConverter.indexOfSurface(XZIndex(x: 2, z: 0), heightmap: heightmap, maxHeight: 10), 2)
        XCTAssertEqual(HeightmapConverter.indexOfSurface(XZIndex(x: 3, z: 0), heightmap: heightmap, maxHeight: 10), 3)
        // highest value in the map
        XCTAssertEqual(HeightmapConverter.indexOfSurface(XZIndex(x: 3, z: 2), heightmap: heightmap, maxHeight: 10), 5)
    }

    func testTwoDIndexNeighborsFrom() throws {
        let neighborsCorner = HeightmapConverter.twoDIndexNeighborsFrom(position: XZIndex(x: 0, z: 0), widthCount: 3, depthCount: 3)
        XCTAssertEqual(neighborsCorner.count, 3)

        let neighborsMid = HeightmapConverter.twoDIndexNeighborsFrom(position: XZIndex(x: 1, z: 1), widthCount: 3, depthCount: 3)
        XCTAssertEqual(neighborsMid.count, 8)

        let neighborsSide = HeightmapConverter.twoDIndexNeighborsFrom(position: XZIndex(x: 1, z: 0), widthCount: 3, depthCount: 3)
        XCTAssertEqual(neighborsSide.count, 5)

        let neighborsFarCorner = HeightmapConverter.twoDIndexNeighborsFrom(position: XZIndex(x: 3, z: 2), widthCount: 4, depthCount: 3)
        XCTAssertEqual(neighborsFarCorner.count, 3)
    }

    func testPointDistanceToLine() throws {
        let p = SIMD3<Float>(0, 0, 0)
        let distance = HeightmapConverter.distanceFromPointToLine(p: p, x1: SIMD3<Float>(1, 1, 0), x2: SIMD3<Float>(1, -1, 0))
        XCTAssertEqual(distance, 1)

        XCTAssertEqual(HeightmapConverter.distanceFromPointToLine(p: p, x1: SIMD3<Float>(2, 0, 0), x2: SIMD3<Float>(0, 2, 0)), sqrt(2.0), accuracy: 0.01)
    }

    func testSDFValueAtHeight() throws {
        // Example unit-value mapping for a max voxel height of 5
        //    +---
        //  4 | .  --> 1.00
        //    +---
        //  3 | .  --> 0.75
        //    +---
        //  2 | .  --> 0.50
        //    +---
        //  1 | .  --> 0.25
        //    +---
        //  0 | .  --> 0.00
        //    +---
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.33, at: 0, maxVoxelHeight: 5, voxelSize: 1.0), -0.33, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.33, at: 1, maxVoxelHeight: 5, voxelSize: 1.0), -0.07, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.33, at: 2, maxVoxelHeight: 5, voxelSize: 1.0), 0.17, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.33, at: 3, maxVoxelHeight: 5, voxelSize: 1.0), 0.33, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.33, at: 4, maxVoxelHeight: 5, voxelSize: 1.0), 0.66, accuracy: 0.1)
    }

    func testClosestDistanceReduce() throws {
        let distances: [Float] = [0.1, 0.2, -0.05, -0.4]
        XCTAssertEqual(HeightmapConverter.SDFDistanceClosestToSurface(initial: 0.1, values: distances), -0.05)
        XCTAssertEqual(HeightmapConverter.SDFDistanceClosestToSurface(initial: 0.01, values: distances), 0.01)
    }

    func testTinyHeightMapToVoxel() throws {
        let unitFloatValues: [[Float]] = [
            [0.1, 0.1],
            [0.1, 0.5],
        ]
        let heightmap = Heightmap(Array(unitFloatValues.joined()), width: 2)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelHeight: 5, voxelSize: 1.0)
        XCTAssertEqual(voxels.count, 16)
        XCTAssertEqual(voxels.bounds.max.y, 5)

        // height map value of 0.1 should fall half-way between YIndex 0 and 1
        // height map value of 0.5 should fall half-way between YIndex 2 and 3
        // therefore, ALL the voxels in x/z 1,1 between y of 0 and y of 3 should have explicit values
        XCTAssertNil(voxels._contents[VoxelIndex(1, 5, 1)])
        XCTAssertNil(voxels._contents[VoxelIndex(1, 4, 1)])
        XCTAssertNotNil(voxels._contents[VoxelIndex(1, 3, 1)])
        XCTAssertNotNil(voxels._contents[VoxelIndex(1, 2, 1)])
        XCTAssertNotNil(voxels._contents[VoxelIndex(1, 1, 1)])
        XCTAssertNotNil(voxels._contents[VoxelIndex(1, 0, 1)])
        // therefore, ALL the voxels in x/z 0,0 between y of 0 and y of 1 should have explicit values
        XCTAssertNil(voxels._contents[VoxelIndex(0, 5, 0)])
        XCTAssertNil(voxels._contents[VoxelIndex(0, 4, 0)])
        XCTAssertNotNil(voxels._contents[VoxelIndex(0, 3, 0)])
        XCTAssertNotNil(voxels._contents[VoxelIndex(0, 2, 0)])
        XCTAssertNotNil(voxels._contents[VoxelIndex(0, 1, 0)])
        XCTAssertNotNil(voxels._contents[VoxelIndex(0, 0, 0)])

        XCTAssertEqual(voxels._contents[VoxelIndex(0, 0, 0)], -0.5)
        XCTAssertEqual(voxels._contents[VoxelIndex(0, 1, 0)], 0.5)

        voxels.dump()

        for voxelValue in voxels {
            XCTAssertTrue(!voxelValue.isNaN)
        }

//        let dumpedHeights: Heightmap = HeightmapConverter.heightmap(from: voxels)
//        XCTAssertEqual([0.1, 0.1, 0.1, 0.5], dumpedHeights.contents)
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
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelHeight: 5, voxelSize: 1.0)
        // XCTAssertEqual(voxels.count, 84)
        for voxelValue in voxels {
            XCTAssertTrue(!voxelValue.isNaN)
        }

        // voxels.dump()
    }

//    func testHeightMapToVoxel() throws {
//        let unitFloatValues: [[Float]] = [
//            [0.1, 0.2, 0.3, 0.4],
//            [0.2, 0.3, 0.4, 0.5],
//            [0.3, 0.4, 0.5, 0.6],
//            [0.4, 0.3, 0.4, 0.2],
//        ]
//        let heightmap = Heightmap(Array(unitFloatValues.joined()), width: 4)
//        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelHeight: 10, voxelSize: 1.0)
//        XCTAssertEqual(voxels.count, 93)
//        for voxelValue in voxels {
//            XCTAssertTrue(!voxelValue.isNaN)
//        }
//
//        XCTAssertEqual(voxels.bounds.max.y, 10)
//        // voxels.dump()
//
//        // FIXME: REVERSING IS NOT WORKING
//        // let dumpedHeights = voxels.heightmap()
//        // XCTAssertEqual([0.1, 0.2, 0.3, 0.4, 0.2, 0.3, 0.4, 0.5, 0.3, 0.4, 0.5, 0.6, 0.4, 0.3, 0.4, 0.2], dumpedHeights)
//    }

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
