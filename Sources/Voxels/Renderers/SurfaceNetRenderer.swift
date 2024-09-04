// Derived from MIT licensed code https://github.com/bonsairobo/fast-surface-nets-rs/blob/main/src/lib.rs

public class SurfaceNetRenderer {
    /// Stride of every voxel that intersects the isosurface. Can be used for efficient post-processing.
    var surface_voxel_indices: [VoxelIndex]

    /// Used to map back from voxel stride to vertex index.
    var voxelIndexToVertexIndex: [VoxelIndex: UInt32]

    public init() {
        surface_voxel_indices = []
        voxelIndexToVertexIndex = [:]
    }

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
    public func render(voxelData: some VoxelAccessible,
                       scale: VoxelScale<Float>,
                       within bounds: VoxelBounds) throws -> MeshBuffer
    {
        var meshbuffer = MeshBuffer()
        // warning shown, or error thrown, when the bounds selected outstrip the bounds
        // of the SDF?

        // set the position and normal into the meshbuffer if the relevant voxel index is a surface voxel
        try estimate_surface(voxelData: voxelData, scale: scale, bounds: bounds, meshbuffer: &meshbuffer)

        try make_all_quads(voxelData: voxelData, bounds: bounds, meshbuffer: &meshbuffer)
        return meshbuffer
    }

    // Find all vertex positions and normals.
    // Also generate a map from grid position to vertex index to be used to look up vertices when generating quads.
    func estimate_surface(
        voxelData: some VoxelAccessible,
        scale: VoxelScale<Float>,
        bounds: VoxelBounds,
        meshbuffer: inout MeshBuffer
    ) throws {
        // iterate throughout all the voxel indices possible within the space of the bounds provided

        // NOTE(heckj): the order of iteration here is extremely important to the assembly of points
        // and quads. I tried replacing the triple-loop with iterating through bounds to linearly
        // increment through the voxel array, and that was a mistake. The rendering results exploded.
        // (as it happens, bounds iteration has "z" on the fastest iteration loop, and "x" on the slowest.
        for z in bounds.min.z ... bounds.max.z {
            for y in bounds.min.y ... bounds.max.y {
                for x in bounds.min.x ... bounds.max.x {
                    // let stride = try voxelData.bounds.linearize(VoxelIndex(x, y, z))
                    // TODO: use a VoxelScale to map this position...
                    // let position = SIMD3<Float>(Float(x), Float(y), Float(z))
                    let thisVoxel = VoxelIndex(x, y, z)
                    if try estimate_surface_in_cube(voxelData: voxelData, scale: scale, cornerIndex: thisVoxel, meshbuffer: &meshbuffer) {
                        voxelIndexToVertexIndex[thisVoxel] = UInt32(meshbuffer.positions.count) - 1
                        surface_voxel_indices.append(thisVoxel)
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
    func estimate_surface_in_cube(
        voxelData: some VoxelAccessible,
        scale: VoxelScale<Float>,
        cornerIndex: VoxelIndex,
        meshbuffer: inout MeshBuffer
    ) throws -> Bool {
        // Get the signed distance values at each corner of this cube.
        var corner_dists: [Float] = Array(repeating: 0.0, count: 8)
        var num_negative = 0

        for i in 0 ... 7 {
            let indexToCheck = cornerIndex.adding(CUBE_CORNERS[i])
            guard let voxelData = voxelData[indexToCheck] else {
                fatalError("unable to check distance at index \(indexToCheck)")
            }
            let d = voxelData.distanceAboveSurface()
            corner_dists[i] = d
            if d < 0 {
                num_negative += 1
            }
        }

        if num_negative == 0 || num_negative == 8 {
            // No crossings.
            return false
        }

        // if there is an intersection, compute the centroid and gradients
        let centroid: SIMD3<Float> = VoxelMeshRenderer.centroid_of_edge_intersections(dists: corner_dists)

        // calculate scaled voxelIndex to floating point position
        let position = scale.cornerPosition(cornerIndex)
        // add the centroid position, scaled and adjusted by the normal corner index
        meshbuffer.positions.append(position + (centroid * scale.cubeSize))
        meshbuffer.normals.append(VoxelMeshRenderer.sdf_gradient(dists: corner_dists, s: centroid))

        return true
    }

    // MARK: Quad generation

    // For every edge that crosses the isosurface, make a quad between the "centers" of the four cubes touching that surface. The
    // "centers" are actually the vertex positions found earlier. Also make sure the triangles are facing the right way. See the
    // comments on `maybe_make_quad` to help with understanding the indexing.
    func make_all_quads(
        voxelData: some VoxelAccessible,
        bounds: VoxelBounds,
        meshbuffer: inout MeshBuffer
    ) throws {
        let xyz_strides: [VoxelIndex] = [
            VoxelIndex(1, 0, 0),
            VoxelIndex(0, 1, 0),
            VoxelIndex(0, 0, 1),
        ]

        for voxel in surface_voxel_indices {
            // Do edges parallel with the X axis
            if voxel.y != bounds.min.y, voxel.z != bounds.min.z, voxel.x != bounds.max.x - 1 {
                maybe_make_quad(
                    voxelData: voxelData,
                    positions: meshbuffer.positions,
                    p1: voxel,
                    p2: voxel.adding(xyz_strides[0]),
                    axis_b_stride: xyz_strides[1],
                    axis_c_stride: xyz_strides[2],
                    indices: &meshbuffer.indices
                )
            }
            // Do edges parallel with the Y axis
            if voxel.x != bounds.min.x, voxel.z != bounds.min.z, voxel.y != bounds.max.y - 1 {
                maybe_make_quad(
                    voxelData: voxelData,
                    positions: meshbuffer.positions,
                    p1: voxel,
                    p2: voxel.adding(xyz_strides[1]),
                    axis_b_stride: xyz_strides[2],
                    axis_c_stride: xyz_strides[0],
                    indices: &meshbuffer.indices
                )
            }
            // Do edges parallel with the Z axis
            if voxel.x != bounds.min.x, voxel.y != bounds.min.y, voxel.z != bounds.max.z - 1 {
                maybe_make_quad(
                    voxelData: voxelData,
                    positions: meshbuffer.positions,
                    p1: voxel,
                    p2: voxel.adding(xyz_strides[2]),
                    axis_b_stride: xyz_strides[0],
                    axis_c_stride: xyz_strides[1],
                    indices: &meshbuffer.indices
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
    func maybe_make_quad(
        voxelData: some VoxelAccessible,
        positions: [SIMD3<Float>],
        p1: VoxelIndex,
        p2: VoxelIndex,
        axis_b_stride: VoxelIndex,
        axis_c_stride: VoxelIndex,
        indices: inout [UInt32]
    ) {
        guard let voxeldata1 = voxelData[p1] else {
            fatalError("unable to read voxel data at \(p1)")
        }
        guard let voxeldata2 = voxelData[p2] else {
            fatalError("unable to read voxel data at \(p2)")
        }

        let d1 = voxeldata1.distanceAboveSurface() // unsafe { sdf.get_unchecked(p1) };
        let d2 = voxeldata2.distanceAboveSurface() // unsafe { sdf.get_unchecked(p2) };

        if (d1 < 0) == true, (d2 < 0) == true { return } // no face - return early
        if (d1 < 0) == false, (d2 < 0) == false { return } // no face - return early

        let negative_face = if (d1 < 0) == true, (d2 < 0) == false {
            false
        } else {
            true
        }
        // if ((d1 < 0) == false) && ((d2 < 0) == true) { negative_face = true }

//        /// Used to map back from voxel stride to vertex index.
//        var voxelIndexToVertexIndex: [VoxelIndex:UInt32]

        // The triangle points, viewed face-front, look like this:
        // v1 v3
        // v2 v4
        guard let v1 = voxelIndexToVertexIndex[p1],
              let v2 = voxelIndexToVertexIndex[p1.subtracting(axis_b_stride)],
              let v3 = voxelIndexToVertexIndex[p1.subtracting(axis_c_stride)],
              let v4 = voxelIndexToVertexIndex[p1.subtracting(axis_b_stride).subtracting(axis_c_stride)]
        else {
            fatalError("")
        }
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
