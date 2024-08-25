// Derived from MIT licensed code https://github.com/bonsairobo/fast-surface-nets-rs/blob/main/src/lib.rs

extension VoxelMeshRenderer {
    /// The Naive Surface Nets smooth voxel meshing algorithm.
    ///
    /// Extracts an isosurface mesh from the [signed distance field](https://en.wikipedia.org/wiki/Signed_distance_function) `sdf`.
    /// Each value in the field determines how close that point is to the isosurface.
    /// Negative values are considered "interior" of the surface volume, and positive values are considered "exterior."
    /// These lattice points will be considered corners of unit cubes.
    /// For each unit cube, at most one isosurface vertex will be estimated.
    /// In the example below, `p` is a positive corner value,
    /// `n` is a negative corner value, `s` is an isosurface vertex,
    /// and `|` or `-` are mesh polygons connecting the vertices.
    ///
    /// ```text
    /// p   p   p   p
    ///   s---s
    /// p | n | p   p
    ///   s   s---s
    /// p | n   n | p
    ///   s---s---s
    /// p   p   p   p
    /// ```
    ///
    /// The set of corners sampled is exactly the set of points in `[min, max]`. `sdf` must contain all of those points.
    ///
    /// Note that the scheme illustrated above implies that chunks must be padded with a 1-voxel border copied from neighboring
    /// voxels in order to connect seamlessly.
    public static func surfaceNetMesh(
        sdf: VoxelArray<Float>,
        within bounds: VoxelBounds
    ) throws -> MeshBuffer {
        // warning shown, or error thrown, when the bounds selected outstrip the bounds
        // of the SDF?
        let inset = sdf.bounds.max.adding(VoxelIndex(-1, -1, -1))
        let insetBounds = VoxelBounds(min: sdf.bounds.min, max: inset)
        precondition(insetBounds.contains(bounds.min))
        precondition(insetBounds.contains(bounds.max))

        var buffer = SurfaceNetsBuffer(arraySize: UInt(sdf.bounds.size))

        try estimate_surface(sdf: sdf, bounds: bounds, output: &buffer)
        try make_all_quads(sdf: sdf, bounds: bounds, output: &buffer)
        return buffer.meshbuffer
    }

    // Find all vertex positions and normals.
    // Also generate a map from grid position to vertex index to be used to look up vertices when generating quads.
    static func estimate_surface(
        sdf: VoxelArray<Float>,
        bounds: VoxelBounds,
        output: inout SurfaceNetsBuffer
    ) throws {
        // iterate throughout all the voxel indices possible within the space of the bounds provided

        // NOTE(heckj): the order of iteration here is extremely important to the assembly of points
        // and quads. I tried replacing the triple-loop with iterating through bounds to linearly
        // increment through the voxel array, and that was a mistake. The rendering results exploded.
        // (as it happens, bounds iteration has "z" on the fastest iteration loop, and "x" on the slowest.
        for z in bounds.min.z ... bounds.max.z {
            for y in bounds.min.y ... bounds.max.y {
                for x in bounds.min.x ... bounds.max.x {
                    let stride = try sdf.bounds.linearize(VoxelIndex(x, y, z))
                    // TODO: use a VoxelScale to map this position...
                    let position = SIMD3<Float>(Float(x), Float(y), Float(z))
                    // this uses both a stride index for internal buffers, and a Float-based position calculated
                    // from the VoxelIndex, in this case a direct mapping of Int -> Float position

                    if try estimate_surface_in_cube(sdf: sdf, position: position, min_corner_stride: stride, output: &output) {
                        output.stride_to_index[Int(stride)] = UInt32(output.meshbuffer.positions.count) - 1
                        output.surface_points.append(
                            SIMD3<UInt32>(x: UInt32(x), y: UInt32(y), z: UInt32(z))
                        )
                        output.surface_strides.append(UInt32(stride))
                    } else {
                        output.stride_to_index[stride] = NULL_VERTEX
                    }
                }
            }
        }
    }

    // Consider the grid-aligned cube where `p` is the minimal corner. Find a point inside this cube that is approximately on the
    // isosurface.
    //
    // This is done by estimating, for each cube edge, where the isosurface crosses the edge (if it does at all). Then the estimated
    // surface point is the average of these edge crossings.
    static func estimate_surface_in_cube(
        sdf: VoxelArray<Float>,
        position: SIMD3<Float>,
        min_corner_stride: Int,
        output: inout SurfaceNetsBuffer
    ) throws -> Bool {
        // Get the signed distance values at each corner of this cube.
        var corner_dists: [Float] = Array(repeating: 0.0, count: 8)
        var num_negative = 0

        for i in 0 ... 7 {
            let additional_stride = try sdf.bounds.linearize(CUBE_CORNERS[i])
            let corner_stride = min_corner_stride + additional_stride
            let d = sdf[corner_stride]
            // let d = *unsafe { sdf.get_unchecked(corner_stride as usize) };
            // *dist = d.into();
            corner_dists[i] = d
            if d < 0 {
                num_negative += 1
            }
        }

        if num_negative == 0 || num_negative == 8 {
            // No crossings.
            return false
        }

        let centroid: SIMD3<Float> = centroid_of_edge_intersections(dists: corner_dists)

        output.meshbuffer.positions.append(position + centroid)
        output.meshbuffer.normals.append(sdf_gradient(dists: corner_dists, s: centroid))

        return true
    }

    static func centroid_of_edge_intersections(dists: [Float]) -> SIMD3<Float> {
        var count = 0
        var sum = SIMD3<Float>.zero
        for corners in CUBE_EDGES {
            let corner1 = corners.x
            let corner2 = corners.y
            let d1 = dists[Int(corner1)]
            let d2 = dists[Int(corner2)]
            if (d1 < 0.0) != (d2 < 0.0) {
                count += 1
                sum += estimate_surface_edge_intersection(corner1: corner1, corner2: corner2, value1: d1, value2: d2)
            }
        }

        return sum / Float(count)
    }

    // Given two cube corners, find the point between them where the SDF is zero. (This might not exist).
    static func estimate_surface_edge_intersection(
        corner1: UInt32,
        corner2: UInt32,
        value1: Float,
        value2: Float
    ) -> SIMD3<Float> {
        let interp1 = value1 / (value1 - value2)
        let interp2 = 1.0 - interp1

        return interp2 * CUBE_CORNER_VECTORS[Int(corner1)]
            + interp1 * CUBE_CORNER_VECTORS[Int(corner2)]
    }

    /// Calculate the normal as the gradient of the distance field. Don't bother making it a unit vector, since we'll do that on the
    /// GPU.
    ///
    /// For each dimension, there are 4 cube edges along that axis. This will do bilinear interpolation between the differences
    /// along those edges based on the position of the surface (s).
    static func sdf_gradient(dists: [Float32], s: SIMD3<Float>) -> SIMD3<Float> {
        let p00 = SIMD3<Float>([dists[0b001], dists[0b010], dists[0b100]])
        let n00 = SIMD3<Float>([dists[0b000], dists[0b000], dists[0b000]])

        let p10 = SIMD3<Float>([dists[0b101], dists[0b011], dists[0b110]])
        let n10 = SIMD3<Float>([dists[0b100], dists[0b001], dists[0b010]])

        let p01 = SIMD3<Float>([dists[0b011], dists[0b110], dists[0b101]])
        let n01 = SIMD3<Float>([dists[0b010], dists[0b100], dists[0b001]])

        let p11 = SIMD3<Float>([dists[0b111], dists[0b111], dists[0b111]])
        let n11 = SIMD3<Float>([dists[0b110], dists[0b101], dists[0b011]])

        // Each dimension encodes an edge delta, giving 12 in total.
        let d00: SIMD3<Float> = p00 - n00 // Edges (0b00x, 0b0y0, 0bz00)
        let d10: SIMD3<Float> = p10 - n10 // Edges (0b10x, 0b0y1, 0bz10)
        let d01: SIMD3<Float> = p01 - n01 // Edges (0b01x, 0b1y0, 0bz01)
        let d11: SIMD3<Float> = p11 - n11 // Edges (0b11x, 0b1y1, 0bz11)

        let neg = SIMD3<Float>.one - s

        // Do bilinear interpolation between 4 edges in each dimension.
        return neg.yzx() * neg.zxy() * d00
            + neg.yzx() * s.zxy() * d10
            + s.yzx() * neg.zxy() * d01
            + s.yzx() * s.zxy() * d11
    }

    // MARK: Quad generation

    // For every edge that crosses the isosurface, make a quad between the "centers" of the four cubes touching that surface. The
    // "centers" are actually the vertex positions found earlier. Also make sure the triangles are facing the right way. See the
    // comments on `maybe_make_quad` to help with understanding the indexing.
    static func make_all_quads(
        sdf: VoxelArray<Float>,
        bounds: VoxelBounds,
        output: inout SurfaceNetsBuffer
    ) throws {
        let xyz_strides: [Int] = try [
            sdf.bounds.linearize([1, 0, 0]),
            sdf.bounds.linearize([0, 1, 0]),
            sdf.bounds.linearize([0, 0, 1]),
        ]

        for (xyz, p_stride) in zip(
            output.surface_points, // [SIMD3<UInt32>]
            output.surface_strides
        ) // [UInt32]
        {
            let p_stride = Int(p_stride)

            // Do edges parallel with the X axis
            if xyz.y != bounds.min.y, xyz.z != bounds.min.z, xyz.x != bounds.max.x - 1 {
                maybe_make_quad(
                    sdf: sdf,
                    stride_to_index: output.stride_to_index,
                    positions: output.meshbuffer.positions,
                    p1: p_stride,
                    p2: p_stride + xyz_strides[0],
                    axis_b_stride: xyz_strides[1],
                    axis_c_stride: xyz_strides[2],
                    indices: &output.meshbuffer.indices
                )
            }
            // Do edges parallel with the Y axis
            if xyz.x != bounds.min.x, xyz.z != bounds.min.z, xyz.y != bounds.max.y - 1 {
                maybe_make_quad(
                    sdf: sdf,
                    stride_to_index: output.stride_to_index,
                    positions: output.meshbuffer.positions,
                    p1: p_stride,
                    p2: p_stride + xyz_strides[1],
                    axis_b_stride: xyz_strides[2],
                    axis_c_stride: xyz_strides[0],
                    indices: &output.meshbuffer.indices
                )
            }
            // Do edges parallel with the Z axis
            if xyz.x != bounds.min.x, xyz.y != bounds.min.y, xyz.z != bounds.max.z - 1 {
                maybe_make_quad(
                    sdf: sdf,
                    stride_to_index: output.stride_to_index,
                    positions: output.meshbuffer.positions,
                    p1: p_stride,
                    p2: p_stride + xyz_strides[2],
                    axis_b_stride: xyz_strides[0],
                    axis_c_stride: xyz_strides[1],
                    indices: &output.meshbuffer.indices
                )
            }
        }
    }

    // Construct a quad in the dual graph of the SDF lattice.
    //
    // The surface point s was found somewhere inside of the cube with minimal corner p1.
    //
    //       x ---- x
    //      /      /|
    //     x ---- x |
    //     |   s  | x
    //     |      |/
    //    p1 --- p2
    //
    // And now we want to find the quad between p1 and p2 where s is a corner of the quad.
    //
    //          s
    //         /|
    //        / |
    //       |  |
    //   p1  |  |  p2
    //       | /
    //       |/
    //
    // If A is (of the three grid axes) the axis between p1 and p2,
    //
    //       A
    //   p1 ---> p2
    //
    // then we must find the other 3 quad corners by moving along the other two axes (those orthogonal to A) in the negative
    // directions; these are axis B and axis C.
    static func maybe_make_quad(
        sdf: VoxelArray<Float>,
        stride_to_index: [UInt32],
        positions: [SIMD3<Float>],
        p1: Int,
        p2: Int,
        axis_b_stride: Int,
        axis_c_stride: Int,
        indices: inout [UInt32]
    ) {
        let d1 = sdf[p1] // unsafe { sdf.get_unchecked(p1) };
        let d2 = sdf[p2] // unsafe { sdf.get_unchecked(p2) };

        if (d1 < 0) == true, (d2 < 0) == true { return } // no face - return early
        if (d1 < 0) == false, (d2 < 0) == false { return } // no face - return early

        let negative_face = if (d1 < 0) == true, (d2 < 0) == false {
            false
        } else {
            true
        }
        // if ((d1 < 0) == false) && ((d2 < 0) == true) { negative_face = true }

        // The triangle points, viewed face-front, look like this:
        // v1 v3
        // v2 v4
        let v1 = stride_to_index[p1]
        let v2 = stride_to_index[p1 - axis_b_stride]
        let v3 = stride_to_index[p1 - axis_c_stride]
        let v4 = stride_to_index[p1 - axis_b_stride - axis_c_stride]
        let (pos1, pos2, pos3, pos4) = (
            positions[Int(v1)],
            positions[Int(v2)],
            positions[Int(v3)],
            positions[Int(v4)]
        )

        // Split the quad along the shorter axis, rather than the longer one.
        let quad = if pos1.distance_squared(pos4) < pos2.distance_squared(pos3) {
            if negative_face {
                [v1, v4, v2, v1, v3, v4]
            } else {
                [v1, v2, v4, v1, v4, v3]
            }
        } else if negative_face {
            [v2, v3, v4, v2, v1, v3]
        } else {
            [v2, v4, v3, v2, v3, v1]
        }
        indices.append(contentsOf: quad)
    }
}
