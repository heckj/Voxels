import Heightmap
@testable import Voxels
import XCTest

final class HeightmapConversionTests: XCTestCase {
    func testUnitCentroidValue() throws {
        // for mapping a heightmap into a Voxel set of centroid SDF values,
        // we need to know the 'unit height' equivalent of the centroid of a voxel.

        // for a max Voxel Index of 5 (Voxels 0...5)
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(0, maxVoxelIndex: 5), 0.0, accuracy: 0.01)
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(1, maxVoxelIndex: 5), 0.2, accuracy: 0.01)
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(2, maxVoxelIndex: 5), 0.4, accuracy: 0.01)
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(3, maxVoxelIndex: 5), 0.6, accuracy: 0.01)
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(4, maxVoxelIndex: 5), 0.8, accuracy: 0.01)
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(5, maxVoxelIndex: 5), 1.0, accuracy: 0.01)
        // stepping above the max height should result in > 1.0 values
        XCTAssertEqual(HeightmapConverter.unitCentroidValue(6, maxVoxelIndex: 5), 1.2, accuracy: 0.01)
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

        XCTAssertEqual(HeightmapConverter.indexOfSurface(XZIndex(x: 0, z: 0), heightmap: heightmap, maxVoxelIndex: 10), 0)
        XCTAssertEqual(HeightmapConverter.indexOfSurface(XZIndex(x: 1, z: 0), heightmap: heightmap, maxVoxelIndex: 10), 1)
        XCTAssertEqual(HeightmapConverter.indexOfSurface(XZIndex(x: 2, z: 0), heightmap: heightmap, maxVoxelIndex: 10), 2)
        XCTAssertEqual(HeightmapConverter.indexOfSurface(XZIndex(x: 3, z: 0), heightmap: heightmap, maxVoxelIndex: 10), 3)
        // highest value in the map
        XCTAssertEqual(HeightmapConverter.indexOfSurface(XZIndex(x: 3, z: 2), heightmap: heightmap, maxVoxelIndex: 10), 5)
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

    func testSizedPositionOfCenter() throws {
        //          size: 1  size: 0.5
        //    +---
        //  4 | .  --> 4      2
        //    +---
        //  3 | .  --> 3      1.5
        //    +---
        //  2 | .  --> 2      1
        //    +---
        //  1 | .  --> 1      0.5
        //    +---
        //  0 | .  --> 0      0
        //    +---

        var result = HeightmapConverter.sizedPositionOfCenter(xz: XZIndex(x: 1, z: 1), y: 1, voxelSize: 1.0)
        XCTAssertEqual(result.x, 1, accuracy: 0.1)
        XCTAssertEqual(result.y, 1, accuracy: 0.1)
        XCTAssertEqual(result.z, 1, accuracy: 0.1)
        result = HeightmapConverter.sizedPositionOfCenter(xz: XZIndex(x: 1, z: 1), y: 3, voxelSize: 0.5)
        XCTAssertEqual(result.x, 0.5, accuracy: 0.1)
        XCTAssertEqual(result.y, 1.5, accuracy: 0.1)
        XCTAssertEqual(result.z, 0.5, accuracy: 0.1)
    }

    func testSizedSurfaceLocation() throws {
        // unit height
        // of 0.33           -> 1.32     -> 0.66
        //
        //             unit    size: 1  size: 0.5
        //    +---
        //  4 | .  --> 1.00      4        2.0
        //    +---
        //  3 | .  --> 0.75      3        1.5
        //    +---
        //  2 | .  --> 0.50      2        1.0
        //    +---
        //  1 | .  --> 0.25      1        0.5
        //    +---
        //  0 | .  --> 0.00      0        0.0
        //    +---

        var result = HeightmapConverter.sizedSurfaceLocation(xz: XZIndex(x: 1, z: 1), unitHeight: 0.33, maxVoxelIndex: 4, voxelSize: 1)
        XCTAssertEqual(result.x, 1, accuracy: 0.1)
        XCTAssertEqual(result.y, 1.32, accuracy: 0.1)
        XCTAssertEqual(result.z, 1, accuracy: 0.1)
        result = HeightmapConverter.sizedSurfaceLocation(xz: XZIndex(x: 1, z: 1), unitHeight: 0.33, maxVoxelIndex: 4, voxelSize: 0.5)
        XCTAssertEqual(result.x, 0.5, accuracy: 0.1)
        XCTAssertEqual(result.y, 0.66, accuracy: 0.1)
        XCTAssertEqual(result.z, 0.5, accuracy: 0.1)
    }

    func testUnitHeightAtIndexWithSDF() throws {
        // For example, for a set of voxels with a maximum voxel index of `4`,
        // a unit-height value of `0.25`, and a voxel size of `1.0`:
        //           unit-value   SDF     SDF
        //           at center   value   value
        //                      (0.25)  (0.33)
        //    +---
        //  4 | .  --> 1.00  ...  3.0   2.68
        //    +---
        //  3 | .  --> 0.75  ...  2.0   1.68
        //    +---
        //  2 | .  --> 0.50  ...  1.0   0.68
        //    +---
        //  1 | .  --> 0.25  ...  0.0  -0.32
        //    +---
        //  0 | .  --> 0.00  ... -1.0  -1.32
        //    +---
        var result = HeightmapConverter.unitHeightValueAtIndex(y: 0, sdf: -1.0, maxVoxelIndex: 4, voxelSize: 1)
        XCTAssertEqual(result, 0.25, accuracy: 0.1)
        result = HeightmapConverter.unitHeightValueAtIndex(y: 1, sdf: -0.32, maxVoxelIndex: 4, voxelSize: 1)
        XCTAssertEqual(result, 0.33, accuracy: 0.1)
    }

    func testSDFValueAtHeight() throws {
        // For example, for a set of voxels with a maximum voxel index of `4`,
        // a unit-height value of `0.25`, and a voxel size of `1.0`:
        //           unit-value   SDF     SDF
        //           at center   value   value
        //                      (0.25)  (0.33)
        //    +---
        //  4 | .  --> 1.00  ...  3.0   2.68
        //    +---
        //  3 | .  --> 0.75  ...  2.0   1.68
        //    +---
        //  2 | .  --> 0.50  ...  1.0   0.68
        //    +---
        //  1 | .  --> 0.25  ...  0.0  -0.32
        //    +---
        //  0 | .  --> 0.00  ... -1.0  -1.32
        //    +---
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.25, at: 4, maxVoxelIndex: 4, voxelSize: 1.0), 3, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.25, at: 3, maxVoxelIndex: 4, voxelSize: 1.0), 2, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.25, at: 2, maxVoxelIndex: 4, voxelSize: 1.0), 1, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.25, at: 1, maxVoxelIndex: 4, voxelSize: 1.0), 0, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.25, at: 0, maxVoxelIndex: 4, voxelSize: 1.0), -1, accuracy: 0.1)

        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.33, at: 4, maxVoxelIndex: 4, voxelSize: 1.0), 2.679, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.33, at: 3, maxVoxelIndex: 4, voxelSize: 1.0), 1.679, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.33, at: 2, maxVoxelIndex: 4, voxelSize: 1.0), 0.679, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.33, at: 1, maxVoxelIndex: 4, voxelSize: 1.0), -0.32, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.33, at: 0, maxVoxelIndex: 4, voxelSize: 1.0), -1.32, accuracy: 0.1)

        // a set of voxels with a maximum voxel index of `4`,
        // a unit-height value of `0.25`, and a voxel size of `0.5`:
        //           unit-value   SDF
        //           at center   value
        //                      (0.25)
        //    +---
        //  4 | .  --> 1.00  ...  2.0
        //    +---
        //  3 | .  --> 0.75  ...  1.5
        //    +---
        //  2 | .  --> 0.50  ...  0.5
        //    +---
        //  1 | .  --> 0.25  ...  0.0
        //    +---
        //  0 | .  --> 0.00  ... -0.5
        //    +---
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.25, at: 4, maxVoxelIndex: 4, voxelSize: 0.5), 1.5, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.25, at: 3, maxVoxelIndex: 4, voxelSize: 0.5), 1, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.25, at: 2, maxVoxelIndex: 4, voxelSize: 0.5), 0.5, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.25, at: 1, maxVoxelIndex: 4, voxelSize: 0.5), 0, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.25, at: 0, maxVoxelIndex: 4, voxelSize: 0.5), -0.5, accuracy: 0.1)

        // verify SDFValueAtHeight isn't acting odd with taller values
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.8, at: 0, maxVoxelIndex: 20, voxelSize: 1), -16.0, accuracy: 0.1)
        XCTAssertEqual(HeightmapConverter.SDFValueAtHeight(0.8, at: 0, maxVoxelIndex: 20, voxelSize: 0.5), -8.0, accuracy: 0.1)
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
        // Example unit-value mapping for a max voxel index of 5, voxel size of 1.0
        //            unit     (0.1)    (0.5)
        // idx       height   SDF val  SDF val
        //    +---
        //  5 | .  --> 1.0     4.5       2.5 +
        //    +---                            \
        //  4 | .  --> 0.8     3.5       1.5 +-+ values above surface that
        //    +---                                don't need to be stored
        //  3 | .  --> 0.6     2.5       0.5
        //    +---
        //  2 | .  --> 0.4     1.5      -0.5
        //    +---
        //  1 | .  --> 0.2     0.5      -1.5
        //    +---
        //  0 | .  --> 0.0    -0.5      -2.5
        //    +---

        let heightmap = Heightmap(Array(unitFloatValues.joined()), width: 2)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 5, voxelSize: 1.0)

        // height map value of 0.1 should fall half-way between Y Index 0 and 1
        // height map value of 0.5 should fall half-way between Y Index 2 and 3
        // with a voxel size of 1.0, that's +/- 0.5 for the relative SDF values

        // And because the algorithm looks only 1 neighbor above the index with a
        // negative value, the Y index values of 4 and 5 aren't used - as long as they're
        // positive for the algorithm, it won't use them.
        // So 4 voxels per level, for levels 0, 1, 2, 3, and 4 - 4*5 = 20 voxels expected
        XCTAssertEqual(voxels.count, 20)
        XCTAssertEqual(voxels.bounds.max.y, 5)

        // Looking at the vertical stack in the lower, right (x=1,z=1) corner:
        XCTAssertNil(voxels._contents[VoxelIndex(1, 5, 1)])
        XCTAssertEqual(voxels._contents[VoxelIndex(1, 4, 1)]!, Float(1.5), accuracy: 0.01)
        XCTAssertEqual(voxels._contents[VoxelIndex(1, 3, 1)]!, Float(0.5), accuracy: 0.01)
        XCTAssertEqual(voxels._contents[VoxelIndex(1, 2, 1)]!, Float(-0.5), accuracy: 0.01)
        XCTAssertEqual(voxels._contents[VoxelIndex(1, 1, 1)]!, Float(-0.67), accuracy: 0.01)
        XCTAssertEqual(voxels._contents[VoxelIndex(1, 0, 1)]!, Float(-1.12), accuracy: 0.01)

        // Looking at the vertical stack in the upper left (x=0,z=0) corner:
        XCTAssertNil(voxels._contents[VoxelIndex(0, 5, 0)])
        // these next two represent a SDF value identified from the wall leading up to the height
        // of one of the neighbors
        XCTAssertEqual(voxels._contents[VoxelIndex(0, 4, 0)]!, Float(2.06), accuracy: 0.01)
        XCTAssertEqual(voxels._contents[VoxelIndex(0, 3, 0)]!, Float(1.5), accuracy: 0.01)
        XCTAssertEqual(voxels._contents[VoxelIndex(0, 2, 0)]!, Float(0.86), accuracy: 0.01)
        XCTAssertEqual(voxels._contents[VoxelIndex(0, 1, 0)]!, Float(0.28), accuracy: 0.01)
        XCTAssertEqual(voxels._contents[VoxelIndex(0, 0, 0)]!, Float(-0.5), accuracy: 0.01)

        voxels.dump()
        // ^^ pretty-prints/inspects the whole set of voxels for debugging/review
//        Frame (Y): 5
//         [0, 5, 0] : 1  [1, 5, 0] : 1
//         [0, 5, 1] : 1  [1, 5, 1] : 1
//
//        Frame (Y): 4
//         [0, 4, 0] : 2.06  [1, 4, 0] : 1.8
//         [0, 4, 1] : 1.8  [1, 4, 1] : 1.5
//
//        Frame (Y): 3
//         [0, 3, 0] : 1.5  [1, 3, 0] : 1.12
//         [0, 3, 1] : 1.12  [1, 3, 1] : 0.5
//
//        Frame (Y): 2
//         [0, 2, 0] : 0.87  [1, 2, 0] : 0.67
//         [0, 2, 1] : 0.67  [1, 2, 1] : -0.5
//
//        Frame (Y): 1
//         [0, 1, 0] : 0.29  [1, 1, 0] : 0.22
//         [0, 1, 1] : 0.22  [1, 1, 1] : -0.67
//
//        Frame (Y): 0
//         [0, 0, 0] : -0.5  [1, 0, 0] : -0.5
//         [0, 0, 1] : -0.5  [1, 0, 1] : -1.12

        for voxelValue in voxels {
            XCTAssertTrue(!voxelValue.isNaN)
        }

        let dumpedHeights = HeightmapConverter.heightmap(from: voxels, voxelSize: 1.0)
        // "[0.1, 0.1, 0.1, 0.5]") is not equal to ("[-0.5, -0.5, -0.5, -0.099999964]"
        XCTAssertEqual(heightmap.contents, dumpedHeights.contents)
    }

    func testSmallHeightMapToVoxel() throws {
        // this test is explicitly checking the values that "sink down" in the lower right corner
        let unitFloatValues: [[Float]] = [
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.5, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.0],
        ]
        let heightmap = Heightmap(Array(unitFloatValues.joined()), width: 5)

        let quickcheck: Int = HeightmapConverter.indexOfSurface(XZIndex(x: 3, z: 3), heightmap: heightmap, maxVoxelIndex: 5)
        XCTAssertEqual(quickcheck, 1) // floating point quirk rounding makes this come out as 1, since the internal float value is computed as 4.0000003 or something. So the next "lowest" integer where the value < 0 is 1.

        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 5, voxelSize: 1.0)

        XCTAssertEqual(voxels.count, 109)
        for voxelValue in voxels {
            XCTAssertTrue(!voxelValue.isNaN)
        }

        // voxels.dump()
        // max voxel index 5 & unit height values are centers
        //    +---
        //  5 | .  --> 1.0
        //    +---
        //  4 | .  --> 0.8
        //    +---
        //  3 | .  --> 0.6
        //    +---
        //  2 | .  --> 0.4
        //    +---
        //  1 | .  --> 0.2
        //    +---
        //  0 | .  --> 0.0
        //    +---

        // unit-height of 0.4 maps to index position 2
        // unit-height of 0.5 is between 2 and 3
        // unit-height of 0 is 0

//        Frame (Y): 3
//         [0, 3, 0] : 1  [1, 3, 0] : 1  [2, 3, 0] : 1  [3, 3, 0] : 1  [4, 3, 0] : 1
//         [0, 3, 1] : 1  [1, 3, 1] : 1  [2, 3, 1] : 1  [3, 3, 1] : 1  [4, 3, 1] : 1
//         [0, 3, 2] : 1  [1, 3, 2] : 1  [2, 3, 2] : 0.5  [3, 3, 2] : 1  [4, 3, 2] : 1
//         [0, 3, 3] : 1  [1, 3, 3] : 1  [2, 3, 3] : 1  [3, 3, 3] : 1  [4, 3, 3] : 1
//         [0, 3, 4] : 1  [1, 3, 4] : 1  [2, 3, 4] : 1  [3, 3, 4] : 1  [4, 3, 4] : 1.41

        // [4,3,4] closest surface point is all below, most likely [4,2,3] which should be
        // a distance of about 1.4 (sqrt(2)

//        Frame (Y): 2
//         [0, 2, 0] : 0  [1, 2, 0] : 0  [2, 2, 0] : 0  [3, 2, 0] : 0  [4, 2, 0] : 0
//         [0, 2, 1] : 0  [1, 2, 1] : 0  [2, 2, 1] : 0  [3, 2, 1] : 0  [4, 2, 1] : 0
//         [0, 2, 2] : 0  [1, 2, 2] : 0  [2, 2, 2] : -0.5  [3, 2, 2] : 0  [4, 2, 2] : 0
//         [0, 2, 3] : 0  [1, 2, 3] : 0  [2, 2, 3] : 0  [3, 2, 3] : 0  [4, 2, 3] : 0
//         [0, 2, 4] : 0  [1, 2, 4] : 0  [2, 2, 4] : 0  [3, 2, 4] : 0  [4, 2, 4] : 1

        //  4,2,4, unit height 0, should be a positive at this vertical slice - not 0, surface
        XCTAssertEqual(voxels[VoxelIndex(4, 2, 4)]!, 1, accuracy: 0.1)

//        Frame (Y): 1
//         [0, 1, 0] : -1  [1, 1, 0] : -1  [2, 1, 0] : -1  [3, 1, 0] : -1  [4, 1, 0] : -1
//         [0, 1, 1] : -1  [1, 1, 1] : -1  [2, 1, 1] : -1  [3, 1, 1] : -1  [4, 1, 1] : -1
//         [0, 1, 2] : -1  [1, 1, 2] : -1  [2, 1, 2] : -1.5  [3, 1, 2] : -1  [4, 1, 2] : -1
//         [0, 1, 3] : -1  [1, 1, 3] : -1  [2, 1, 3] : -1  [3, 1, 3] : -1  [4, 1, 3] : -1
//         [0, 1, 4] : -1  [1, 1, 4] : -1  [2, 1, 4] : -1  [3, 1, 4] : -1  [4, 1, 4] : 0.45

        // [4,1,4] is a wall derived value... - the options were 0.45, 0.45, and 0.57, with directly
        // down being 1, so that's working as expected...
        XCTAssertEqual(voxels[VoxelIndex(4, 1, 4)]!, 0.45, accuracy: 0.1)

//        Frame (Y): 0
//         [0, 0, 0] : -2  [1, 0, 0] : -2  [2, 0, 0] : -2  [3, 0, 0] : -2  [4, 0, 0] : -2
//         [0, 0, 1] : -2  [1, 0, 1] : -2  [2, 0, 1] : -2  [3, 0, 1] : -2  [4, 0, 1] : -2
//         [0, 0, 2] : -2  [1, 0, 2] : -2  [2, 0, 2] : -2.24  [3, 0, 2] : -2  [4, 0, 2] : -2
//         [0, 0, 3] : -2  [1, 0, 3] : -2  [2, 0, 3] : -2  [3, 0, 3] : -1.15  [4, 0, 3] : -0.89
//         [0, 0, 4] : -2  [1, 0, 4] : -2  [2, 0, 4] : -2  [3, 0, 4] : -0.89  [4, 0, 4] : 0
        XCTAssertEqual(voxels[VoxelIndex(4, 0, 4)]!, 0, accuracy: 0.1)
    }

    func testHeightMapToVoxel() throws {
        let unitFloatValues: [[Float]] = [
            [0.1, 0.2, 0.3, 0.4],
            [0.2, 0.3, 0.4, 0.5],
            [0.3, 0.4, 0.5, 0.6],
            [0.4, 0.3, 0.4, 0.2],
        ]
        let heightmap = Heightmap(Array(unitFloatValues.joined()), width: 4)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 10, voxelSize: 1.0)
        XCTAssertEqual(voxels.count, 108)
        for voxelValue in voxels {
            XCTAssertTrue(!voxelValue.isNaN)
        }
        XCTAssertEqual(voxels.bounds.max.y, 10)
        // voxels.dump()

        let dumpedHeights = HeightmapConverter.heightmap(from: voxels, voxelSize: 1.0)
        XCTAssertEqual(heightmap.contents, dumpedHeights.contents)
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

    func testHeightMapToFloor() throws {
        let unitFloatValues: [[Float]] = [
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.5, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.1],
        ]
        let heightmap = Heightmap(Array(unitFloatValues.joined()), width: 5)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 20, voxelSize: 1.0, extendToFloor: true)
        XCTAssertEqual(voxels.count, 268) // extendToFloor == false : 142

        voxels.dump()

        // verify all of the floor voxels contain values
        for i in 0 ... 4 {
            for j in 0 ... 4 {
                XCTAssertNotNil(voxels._contents[VoxelIndex(i, 0, j)])
                XCTAssertTrue(voxels._contents[VoxelIndex(i, 0, j)]! < 0.0)
            }
        }
    }

    func testNeighborSDFCalculation() throws {
        let unitFloatValues: [[Float]] = [
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.5, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.4],
            [0.4, 0.4, 0.4, 0.4, 0.1],
        ]
        let heightmap = Heightmap(Array(unitFloatValues.joined()), width: 5)
        var voxels = VoxelHash<Float>()

        voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 20, voxelSize: 1.0, extendToFloor: true)
        // voxels.dump()

        // prep work for the internal function

        // get the X and Z coordinate index for this column of voxels from the height map
        let xzPosition = XZIndex(x: 4, z: 3)
        let y = 2
        let value = heightmap[xzPosition]
        let maxVoxelIndex = 20
        let voxelSize: Float = 1.0

        // compute a list of the valid neighbor X and Z coordinates that are within the bounds
        // of the height map
        let surroundingNeighbors: [XZIndex] = HeightmapConverter.twoDIndexNeighborsFrom(position: xzPosition, widthCount: heightmap.width, depthCount: heightmap.height)

        // get a list of the VoxelIndex positions of the surface for the neighbor voxel columns
        let neighborsSurfaceVoxelIndex: [VoxelIndex] = surroundingNeighbors.map { xz in
            let yIndexForNeighbor = HeightmapConverter.indexOfSurface(xz, heightmap: heightmap, maxVoxelIndex: maxVoxelIndex)
            return VoxelIndex(xz.x, yIndexForNeighbor, xz.z)
        }

        let yIndex = HeightmapConverter.indexOfSurface(value, maxVoxelIndex: maxVoxelIndex)

        let minYIndexOfNeighbors: Int = neighborsSurfaceVoxelIndex.reduce(yIndex) { partialResult, vIndex in
            Swift.min(partialResult, vIndex.y)
        }
        let maxYIndexOfNeighbors: Int = neighborsSurfaceVoxelIndex.reduce(yIndex) { partialResult, vIndex in
            Swift.max(partialResult, vIndex.y)
        }

//        Frame (Y): 2
//         [0, 2, 0] : -6  [1, 2, 0] : -6  [2, 2, 0] : -6  [3, 2, 0] : -6  [4, 2, 0] : -6
//         [0, 2, 1] : -6  [1, 2, 1] : -6  [2, 2, 1] : -6  [3, 2, 1] : -6  [4, 2, 1] : -6
//         [0, 2, 2] : -6  [1, 2, 2] : -6  [2, 2, 2] : -6.08  [3, 2, 2] : -6  [4, 2, 2] : -6
//         [0, 2, 3] : -6  [1, 2, 3] : -6  [2, 2, 3] : -6  [3, 2, 3] : -1.38  [4, 2, 3] : -0.99
//         [0, 2, 4] : -6  [1, 2, 4] : -6  [2, 2, 4] : -6  [3, 2, 4] : -0.99  [4, 2, 4] : 0

        HeightmapConverter.populateVoxelWithSDF(y, xzPosition: xzPosition, ySurfaceIndex: yIndex, heightmap: heightmap, unitHeightSurfaceValue: value, maxVoxelIndex: maxVoxelIndex, voxelSize: voxelSize, minYIndexOfNeighbors: minYIndexOfNeighbors, maxYIndexOfNeighbors: maxYIndexOfNeighbors, surroundingNeighbors: surroundingNeighbors, voxels: &voxels)
        XCTAssertEqual(voxels[VoxelIndex(xzPosition.x, y, xzPosition.z)]!, Float(-0.99), accuracy: 0.1)
    }
}
