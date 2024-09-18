@testable import Voxels
import XCTest

final class SurfaceNetRendererUtilityTests: XCTestCase {
    func testEstimateSurfaceEdgeIntersection0() throws {
        // corner1: Int, // index into CUBE_CORNER_VECTORS
        // corner2: Int, // index into CUBE_CORNER_VECTORS
        // value1: Float, // SDF value at that corner
        // value2: Float // SDF value at that corner

        // corner 0 (0,0,0) - SDF value is 0.5
        // corner 1 (1,0,0) - SDF value is -0.5
        let result = SurfaceNetRenderer.estimateSurfaceEdgeIntersection(corner1: 0, corner2: 1, value1: 0.5, value2: -0.5)
        let expected = SIMD3<Float>(0.5, 0, 0)
        XCTAssertEqual(result.x, expected.x, accuracy: 0.01)
        XCTAssertEqual(result.y, expected.y, accuracy: 0.01)
        XCTAssertEqual(result.z, expected.z, accuracy: 0.01)
    }

    func testEstimateSurfaceEdgeIntersection1() throws {
        // corner1: Int, // index into CUBE_CORNER_VECTORS
        // corner2: Int, // index into CUBE_CORNER_VECTORS
        // value1: Float, // SDF value at that corner
        // value2: Float // SDF value at that corner

        // corner 0 (0,0,0) - SDF value is 1
        // corner 1 (1,0,0) - SDF value is 0
        let result = SurfaceNetRenderer.estimateSurfaceEdgeIntersection(corner1: 0, corner2: 1, value1: 1, value2: 0)
        let expected = SIMD3<Float>(1, 0, 0)
        XCTAssertEqual(result.x, expected.x, accuracy: 0.01)
        XCTAssertEqual(result.y, expected.y, accuracy: 0.01)
        XCTAssertEqual(result.z, expected.z, accuracy: 0.01)
    }

    func testCentroidOfIntersections() throws {
        // dists are an array of 8 Float values, in the order that matches the corners
        // of CUBE_CORNERS. The values represent the SDF values at the center of those
        // voxels.
        //
        // SDF Values:
        // - < 0 indicates a distance amount below the surface
        // - == 0 indicates the point is on the surface
        // - > 0 indicates a distance amount above the surface
        //
        // The relative offset by index for the corners:
        //
        //         ^ +Y
        //         |
        //     (2) +-----------------+ (3)
        //         |\                 \
        //         | \                 \
        //         |  \                 \
        //         |   \                 \
        //         |    +-----------------+ (7)
        //         |    |(6)              |
        //         |    |                 |
        //     (0) +    |            +    |-------> +X
        //          \   |           (1)   |
        //           \  |                 |
        //            \ |                 |
        //             \|                 |
        //              +-----------------+
        //           (4) \               (5)
        //                \
        //                _\/
        //                  +Z

        // should represent a perfectly flat plane in the middle of the voxel
        let dists: [Float] = [-0.5, -0.5, 0.5, 0.5, -0.5, -0.5, 0.5, 0.5]
        let result = SurfaceNetRenderer.centroidOfEdgeIntersections(dists: dists)
        let expected = SIMD3<Float>(0.5, 0.5, 0.5)
        XCTAssertEqual(result.x, expected.x, accuracy: 0.01)
        XCTAssertEqual(result.y, expected.y, accuracy: 0.01)
        XCTAssertEqual(result.z, expected.z, accuracy: 0.01)

        // should represent a perfectly flat plane in the middle of the voxel
        let cornerDists: [Float] = [-0.5, 1, 1, 1, 1, 1, 1, 1]
        let cornerResult = SurfaceNetRenderer.centroidOfEdgeIntersections(dists: cornerDists)
        let expectedCorner = SIMD3<Float>(0.11, 0.11, 0.11)
        XCTAssertEqual(cornerResult.x, expectedCorner.x, accuracy: 0.01)
        XCTAssertEqual(cornerResult.y, expectedCorner.y, accuracy: 0.01)
        XCTAssertEqual(cornerResult.z, expectedCorner.z, accuracy: 0.01)
    }
}
