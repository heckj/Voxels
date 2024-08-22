/// The raw data collection that supports generating a MeshDescriptor
public struct MeshBuffer: Sendable {
    /// The triangle mesh positions.
    public var positions: [SIMD3<Float>]

    /// The triangle mesh normals.
    public var normals: [SIMD3<Float>]

    /// The triangle mesh indices.
    public var indices: [UInt32]

    /// Clears all of the buffers, but keeps the memory allocated for reuse.
    public mutating func reset() {
        positions = []
        normals = []
        indices = []
    }

    /// Adds a quad, scaled for the exterior view of the face of the voxel you provide.
    /// - Parameters:
    ///   - index: The index of the voxel.
    ///   - scale: The scale to determine the distance and offsets for the corners.
    ///   - face: The face of the voxel.
    public mutating func addQuad(index: VoxelIndex, scale: VoxelScale<Float>, face: CubeFace) {
        let corners = face.corners(exterior: true)
        let scaledCorners = corners.map { relativeIndex in
            scale.cornerPosition(index.adding(relativeIndex))
        }
        addQuadPoints(p1: scaledCorners[0], p2: scaledCorners[1], p3: scaledCorners[2], p4: scaledCorners[3])
    }

    /// Adds a quad, split along the shorter axis, into the mesh buffer.
    /// - Parameters:
    ///   - p1: A 3D point that represents the top-left corner of the quad.
    ///   - p2: A 3D point that represents the lower-left corner of the quad.
    ///   - p3: A 3D point that represents the upper-right corner of the quad.
    ///   - p4: A 3D point that represents the lower-right corner of the quad.
    ///
    /// The points of the Quad, viewed face-front, are 'wound' in the following order:
    ///  ```
    ///  v1  v3
    ///   | /|
    ///   |/ |
    ///  v2  v4
    /// ```
    public mutating func addQuadPoints(p1: SIMD3<Float>, p2: SIMD3<Float>, p3: SIMD3<Float>, p4: SIMD3<Float>) {
        // The triangle points, viewed face-front, look like this:
        // v1 v3
        // v2 v4
        let baseIndex: Int = positions.count - 1
        positions.append(contentsOf: [p1, p2, p3, p4])

        // calculate a normal value
        let normal = (p2 - p1).cross(p4 - p2).normalized()
        normals.append(contentsOf: [normal, normal, normal, normal])

        // Split the quad along the shorter axis, rather than the longer one.
        if p1.distance_squared(p4) < p2.distance_squared(p3) {
            indices.append(contentsOf: [UInt32(baseIndex + 1), UInt32(baseIndex + 2), UInt32(baseIndex + 4), UInt32(baseIndex + 1), UInt32(baseIndex + 4), UInt32(baseIndex + 3)])
        } else {
            indices.append(contentsOf: [UInt32(baseIndex + 2), UInt32(baseIndex + 4), UInt32(baseIndex + 3), UInt32(baseIndex + 2), UInt32(baseIndex + 3), UInt32(baseIndex + 1)])
        }
    }

    public init(positions: [SIMD3<Float>] = [], indices: [UInt32] = [], normals: [SIMD3<Float>] = []) {
        self.positions = positions
        self.normals = normals
        self.indices = indices
    }
}
