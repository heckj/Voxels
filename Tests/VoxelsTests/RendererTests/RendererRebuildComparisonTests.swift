@testable import Voxels
import XCTest

final class RendererRebuildComparisonTests: XCTestCase {
    func testSurfaceNetRendererComparison() throws {
        let samples = try SampleMeshData.voxelArrayFromSphere()

        let originalResultBuffer = try VoxelMeshRenderer.surfaceNetMesh(
            sdf: samples,
            within: VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(32, 32, 32))
        )

        let newThing = SurfaceNetRenderer()
        let newResultBuffer = try newThing.render(voxelData: samples, scale: .init(), within: samples.bounds.insetQuadrant())

        XCTAssertEqual(newResultBuffer.positions, originalResultBuffer.positions)
        XCTAssertEqual(newResultBuffer.indices.count, originalResultBuffer.indices.count)

        XCTAssertTrue(newResultBuffer.positions.count > 1)
        XCTAssertTrue(newResultBuffer.indices.count > 1)
    }

    func testEstimateSurfaceComparison() throws {
        let samples = try SampleMeshData.voxelArrayFromSphere()
        print(samples.bounds)
        let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(32, 32, 32))
        XCTAssertTrue(samples.bounds.contains(bounds))

        // this explicitly needs the bigger set of bounds to check against
        var buffer = SurfaceNetsBuffer(arraySize: UInt(samples.bounds.size))

        try VoxelMeshRenderer.estimate_surface(sdf: samples, bounds: bounds, output: &buffer)

        XCTAssertEqual(buffer.surface_points.count, 1160)
        XCTAssertEqual(buffer.surface_strides.count, 1160)
        XCTAssertEqual(buffer.stride_to_index.count, 39304)
        // stride_to_index lookup is MUCH bigger than I anticipated
        // ^^ 34^3 (0...33 x 0...33 x 0...33)
        // - most of this, other than the surface points, are references to NULL_INDEX

        XCTAssertEqual(buffer.maybe_make_quad_call_count, 0)

        try VoxelMeshRenderer.make_all_quads(sdf: samples, bounds: bounds, output: &buffer)

        XCTAssertEqual(buffer.surface_points.count, 1160)
        XCTAssertEqual(buffer.surface_strides.count, 1160)
        XCTAssertEqual(buffer.stride_to_index.count, 39304)

        XCTAssertEqual(buffer.maybe_make_quad_call_count, 3480)
        XCTAssertEqual(buffer.meshbuffer.positions.count, 1160)
        XCTAssertEqual(buffer.meshbuffer.normals.count, 1160)
        XCTAssertEqual(buffer.meshbuffer.indices.count, 6948)

        // MARK: new part which isn't matching...

        let newThing = SurfaceNetRenderer()
        // The insides of the newThing.render() command
        newThing.resetCache()
        try newThing.estimateSurface(voxelData: samples, scale: .init(), bounds: samples.bounds.insetQuadrant())

        XCTAssertEqual(newThing.surface_voxel_indices.count, 1160)
        XCTAssertEqual(newThing.positionsCache.count, 1160)
        XCTAssertEqual(newThing.normalsCache.count, 1160)
        XCTAssertEqual(newThing.indicesCache.count, 0)

        XCTAssertEqual(newThing.maybe_make_quad_call_count, 0)
        try newThing.makeAllQuads(voxelData: samples, bounds: bounds)

        XCTAssertEqual(newThing.maybe_make_quad_call_count, 3480)
        XCTAssertEqual(newThing.maybe_make_was_yes, 1158)

        // So we're calling this the same number of times, the out iteration loop isn't the issue.
        XCTAssertEqual(newThing.indicesCache.count, 6948 / 6)
        // for equivalence it should be 1158 - underrepresenting the indices here

        let newResultBuffer = newThing.assembleMeshBufferFromCache()
        XCTAssertEqual(newResultBuffer.positions, buffer.meshbuffer.positions)
        // XCTAssertEqual(newResultBuffer.indices, buffer.meshbuffer.indices)

        // So let's check all the results from the original algorithm and see how they compare to individual calls to the new one

        var doubleCheckCallCount = 0
        var maybeWasYesCount = 0
        var output = buffer
        let sdf = samples
        let xyz_strides: [Int] = try [
            samples.bounds.linearize([1, 0, 0]),
            samples.bounds.linearize([0, 1, 0]),
            samples.bounds.linearize([0, 0, 1]),
        ]

        let bigThing = zip(
            output.surface_points, // [SIMD3<UInt32>]
            output.surface_strides // [UInt32]
        ) // this results in 1160 items  - so it's the same as iterating over the surface voxel indices

        let newThing_xyz_strides: [VoxelIndex] = [
            VoxelIndex(1, 0, 0),
            VoxelIndex(0, 1, 0),
            VoxelIndex(0, 0, 1),
        ]

        var voxelIndexToVertexIndexLookup: [VoxelIndex: Int] = [:]
        // build the vertex index lookup table for the test
        for (index, voxelindex) in newThing.surface_voxel_indices.enumerated() {
            voxelIndexToVertexIndexLookup[voxelindex] = index
        }

        for (xyz, p_stride) in bigThing {
            let p_stride = Int(p_stride)

            // Do edges parallel with the X axis
            if xyz.y != bounds.min.y, xyz.z != bounds.min.z, xyz.x != bounds.max.x - 1 {
                doubleCheckCallCount += 1
                let resultingQuad = VoxelMeshRenderer.maybe_make_quad(
                    sdf: sdf,
                    stride_to_index: output.stride_to_index,
                    positions: output.meshbuffer.positions,
                    p1: p_stride,
                    p2: p_stride + xyz_strides[0],
                    axis_b_stride: xyz_strides[1],
                    axis_c_stride: xyz_strides[2],
                    indices: &output.meshbuffer.indices
                )
                if !resultingQuad.isEmpty {
                    maybeWasYesCount += 1
                    XCTAssertEqual(resultingQuad.count, 6)
                    // compare to the new algorithm, converting stuff...
                    let v1 = output.stride_to_index[p_stride]
                    let position = output.meshbuffer.positions[Int(v1)]
                    // print(position)
                    if let cacheFind = newThing.positionsCache.first(where: { _, value in
                        value == position
                    }) {
                        // print(cacheFind) // key, value from cache lookup

                        let tryingNewThingMakeQuad = newThing.maybeMakeQuad(
                            voxelData: sdf,
                            p1: cacheFind.0,
                            p2: cacheFind.0.adding(newThing_xyz_strides[0]),
                            axis_b_stride: newThing_xyz_strides[1],
                            axis_c_stride: newThing_xyz_strides[2]
                        )
                        // print(tryingNewThingMakeQuad)
                        XCTAssertEqual(tryingNewThingMakeQuad.count, 6)
                        XCTAssertFalse(tryingNewThingMakeQuad.isEmpty)
                        let directIndexPositionComparison = tryingNewThingMakeQuad.compactMap { voxelindex in
                            if let indexPosition = voxelIndexToVertexIndexLookup[voxelindex] {
                                return UInt32(indexPosition)
                            }
                            return nil
                        }
                        XCTAssertEqual(directIndexPositionComparison.count, 6)
                        XCTAssertEqual(resultingQuad, directIndexPositionComparison)
                    } else {
                        XCTFail("MISSING CACHE COMPARISON")
                    }
                }
            }
            // Do edges parallel with the Y axis
            if xyz.x != bounds.min.x, xyz.z != bounds.min.z, xyz.y != bounds.max.y - 1 {
                doubleCheckCallCount += 1
                let resultingQuad = VoxelMeshRenderer.maybe_make_quad(
                    sdf: sdf,
                    stride_to_index: output.stride_to_index,
                    positions: output.meshbuffer.positions,
                    p1: p_stride,
                    p2: p_stride + xyz_strides[1],
                    axis_b_stride: xyz_strides[2],
                    axis_c_stride: xyz_strides[0],
                    indices: &output.meshbuffer.indices
                )
                if !resultingQuad.isEmpty {
                    maybeWasYesCount += 1
                    XCTAssertEqual(resultingQuad.count, 6)
                    // compare to the new algorithm, converting stuff...
                    let v1 = output.stride_to_index[p_stride]
                    let position = output.meshbuffer.positions[Int(v1)]
                    // print(position)
                    if let cacheFind = newThing.positionsCache.first(where: { _, value in
                        value == position
                    }) {
                        // print(cacheFind) // key, value from cache lookup

                        let tryingNewThingMakeQuad = newThing.maybeMakeQuad(
                            voxelData: sdf,
                            p1: cacheFind.0,
                            p2: cacheFind.0.adding(newThing_xyz_strides[1]),
                            axis_b_stride: newThing_xyz_strides[2],
                            axis_c_stride: newThing_xyz_strides[0]
                        )
                        // print(tryingNewThingMakeQuad)
                        XCTAssertEqual(tryingNewThingMakeQuad.count, 6)
                        XCTAssertFalse(tryingNewThingMakeQuad.isEmpty)
                        let directIndexPositionComparison = tryingNewThingMakeQuad.compactMap { voxelindex in
                            if let indexPosition = voxelIndexToVertexIndexLookup[voxelindex] {
                                return UInt32(indexPosition)
                            }
                            return nil
                        }
                        XCTAssertEqual(directIndexPositionComparison.count, 6)
                        XCTAssertEqual(resultingQuad, directIndexPositionComparison)
                    } else {
                        XCTFail("MISSING CACHE COMPARISON")
                    }
                }
            }
            // Do edges parallel with the Z axis
            if xyz.x != bounds.min.x, xyz.y != bounds.min.y, xyz.z != bounds.max.z - 1 {
                doubleCheckCallCount += 1
                let resultingQuad = VoxelMeshRenderer.maybe_make_quad(
                    sdf: sdf,
                    stride_to_index: output.stride_to_index,
                    positions: output.meshbuffer.positions,
                    p1: p_stride,
                    p2: p_stride + xyz_strides[2],
                    axis_b_stride: xyz_strides[0],
                    axis_c_stride: xyz_strides[1],
                    indices: &output.meshbuffer.indices
                )
                if !resultingQuad.isEmpty {
                    maybeWasYesCount += 1
                    XCTAssertEqual(resultingQuad.count, 6)
                    // compare to the new algorithm, converting stuff...
                    let v1 = output.stride_to_index[p_stride]
                    let position = output.meshbuffer.positions[Int(v1)]
                    // print(position)
                    if let cacheFind = newThing.positionsCache.first(where: { _, value in
                        value == position
                    }) {
                        // print(cacheFind) // key, value from cache lookup

                        let tryingNewThingMakeQuad = newThing.maybeMakeQuad(
                            voxelData: sdf,
                            p1: cacheFind.0,
                            p2: cacheFind.0.adding(newThing_xyz_strides[2]),
                            axis_b_stride: newThing_xyz_strides[0],
                            axis_c_stride: newThing_xyz_strides[1]
                        )
                        // print(tryingNewThingMakeQuad)
                        XCTAssertFalse(tryingNewThingMakeQuad.isEmpty)
                        XCTAssertEqual(tryingNewThingMakeQuad.count, 6)
                        let directIndexPositionComparison = tryingNewThingMakeQuad.compactMap { voxelindex in
                            if let indexPosition = voxelIndexToVertexIndexLookup[voxelindex] {
                                return UInt32(indexPosition)
                            }
                            return nil
                        }
                        XCTAssertEqual(directIndexPositionComparison.count, 6)
                        XCTAssertEqual(resultingQuad, directIndexPositionComparison)
                    } else {
                        XCTFail("MISSING CACHE COMPARISON")
                    }
                }
            }
        }
        XCTAssertEqual(doubleCheckCallCount, 3480)
        XCTAssertEqual(maybeWasYesCount, 1158)
        // print("Maybe Was Yes \(maybeWasYesCount) times")
    }
}
