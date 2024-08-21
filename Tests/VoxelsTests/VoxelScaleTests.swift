import Voxels
import XCTest

class VoxelScaleTests: XCTestCase {
    func testVoxelScaleFloat() throws {
        let scale = VoxelScale(origin: SIMD3<Float>(0, 0, 0), cubeSize: 1.0)
        let v = VoxelArray(edge: 3, value: 1, origin: SIMD3<Float>(0, 0, 0), edgeLength: 1.0)
        let bounds = try XCTUnwrap(v.bounds)

        // inner corner of initial voxel
        XCTAssertEqual(scale.cornerPosition(bounds.min), SIMD3<Float>(0, 0, 0))

        // inner corner of final voxel
        XCTAssertEqual(scale.cornerPosition(bounds.max), SIMD3<Float>(2, 2, 2))
        // outer corner of final voxel
        XCTAssertEqual(scale.cornerPosition(bounds.max.adding(CUBE_CORNERS[7])), SIMD3<Float>(3, 3, 3))
    }

    func testVoxelScaleCentroid() throws {
        let scale = VoxelScale(origin: SIMD3<Float>(0, 0, 0), cubeSize: 1.0)
        let v = VoxelArray(edge: 3, value: 1, origin: SIMD3<Float>(0, 0, 0), edgeLength: 1.0)
        let bounds = try XCTUnwrap(v.bounds)

        // centroid position of initial voxel
        XCTAssertEqual(scale.centroidPosition(bounds.min), SIMD3<Float>(0.5, 0.5, 0.5))
    }

    func testVoxelScaleInteger() throws {
        let scale = VoxelScale(origin: SIMD3<Int>(0, 0, 0), cubeSize: 1)
        let v = VoxelArray(edge: 3, value: 1, origin: SIMD3<Int>(0, 0, 0), edgeLength: 0)
        let bounds = try XCTUnwrap(v.bounds)

        // inner corner of initial voxel
        XCTAssertEqual(scale.cornerPosition(bounds.min), SIMD3<Int>(0, 0, 0))

        // inner corner of final voxel
        XCTAssertEqual(scale.cornerPosition(bounds.max), SIMD3<Int>(2, 2, 2))
        // outer corner of final voxel
        XCTAssertEqual(scale.cornerPosition(bounds.max.adding(CUBE_CORNERS[7])), SIMD3<Int>(3, 3, 3))
    }

    func testVoxelDomainIndex() throws {
        let scale = VoxelScale(origin: SIMD3<Float>(0, 0, 0), cubeSize: 1.0)

        XCTAssertEqual(scale.index(for: SIMD3<Float>(0, 0, 0)), VoxelIndex(0, 0, 0))
        XCTAssertEqual(scale.index(for: SIMD3<Float>(0.1, 0.1, 0.1)), VoxelIndex(0, 0, 0))
        XCTAssertEqual(scale.index(for: SIMD3<Float>(0.9, 0.9, 0.9)), VoxelIndex(0, 0, 0))

        XCTAssertEqual(scale.index(for: SIMD3<Float>(1.0, 1.0, 1.0)), VoxelIndex(1, 1, 1))
        XCTAssertEqual(scale.index(for: SIMD3<Float>(1.1, 1.1, 1.1)), VoxelIndex(1, 1, 1))
        XCTAssertEqual(scale.index(for: SIMD3<Float>(1.9, 1.9, 1.9)), VoxelIndex(1, 1, 1))
    }
}
