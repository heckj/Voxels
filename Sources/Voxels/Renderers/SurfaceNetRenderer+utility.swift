extension SurfaceNetRenderer {
    /// Returns the estimated point between the 8 corners of the index positions of voxels, where a vertex
    /// should reside that best represents the surface, inferred from the SDF values at those index positions.
    /// - Parameter dists: The SDF float values at each of the corners.
    /// - Returns: an estimated `SIMD3<Float>` in unit coordinates from the leading corner of this vertex.
    static func centroidOfEdgeIntersections(dists: [Float]) -> SIMD3<Float> {
        precondition(dists.count == 8)
        var count = 0
        var sum = SIMD3<Float>.zero
        for corners in CUBE_EDGES {
            let corner1: Int = corners.x // index of CUBE_CORNER_VECTORS
            let corner2: Int = corners.y // index of CUBE_CORNER_VECTORS
            let d1 = dists[corner1]
            let d2 = dists[corner2]
            if (d1 < 0.0) != (d2 < 0.0) {
                count += 1
                sum += estimateSurfaceEdgeIntersection(corner1: corner1, corner2: corner2, value1: d1, value2: d2)
            }
        }

        return sum / Float(count)
    }

    /// Given the SDF values at the index positions of two corners, estimate
    /// where - between those positions - the SDF value is zero.
    ///
    /// If the SDF values between two corners provided don't have different signs,
    /// there is no valid resulting value.
    ///
    /// - Parameters:
    ///   - corner1: The index value for the first corner.
    ///   - corner2: The index value for the second corner.
    ///   - value1: The SDF value at the first corner.
    ///   - value2: The SDF Value at the second corner.
    /// - Returns: The interpolated position as `SIMD3<Float>` between the two corners where the surface resides.
    static func estimateSurfaceEdgeIntersection(
        corner1: Int, // index of CUBE_CORNER_VECTORS
        corner2: Int, // index of CUBE_CORNER_VECTORS
        value1: Float, // SDF value at that corner
        value2: Float // SDF value at that corner
    ) -> SIMD3<Float> {
        let interp1 = value1 / (value1 - value2)
        let interp2 = 1.0 - interp1

        return interp2 * CUBE_CORNER_VECTORS[corner1]
            + interp1 * CUBE_CORNER_VECTORS[corner2]
    }

    /// Calculate the normal as the gradient of the distance field.
    ///
    /// For each dimension, there are 4 cube edges along the corresponding axis.
    /// This method does bilinear interpolation between the differences along those edges
    /// based on the position of the surface (s).
    static func sdfGradient(dists: [Float32], s: SIMD3<Float>) -> SIMD3<Float> {
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
        let interpolatedResult: SIMD3<Float> = neg.yzx() * neg.zxy() * d00
            + neg.yzx() * s.zxy() * d10
            + s.yzx() * neg.zxy() * d01
            + s.yzx() * s.zxy() * d11
        return interpolatedResult.normalized()
    }
}
