import Foundation

/// A buffer of vertex indices, positions and normals that make up a generated 3D mesh.
///
///
public struct MeshBuffer: Sendable {
    /// The triangle mesh positions.
    public var positions: [SIMD3<Float>]

    /// The triangle mesh normals.
    public var normals: [SIMD3<Float>]

    /// The triangle mesh indices.
    public var indices: [UInt32]

    public var triangles: Int {
        indices.count / 3
    }

    public var quads: Int {
        triangles / 2
    }

    public var memSize: Int {
        // a loose estimate of size of memory consumed by this buffer in RAM
        indices.count * MemoryLayout<UInt32>.size +
            (positions.count + normals.count) * MemoryLayout<SIMD3<Float>>.size
    }

    public func validate() throws {
        if positions.isEmpty || normals.isEmpty {
            throw GeneratedMeshError.empty
        }
        if positions.count != normals.count {
            throw GeneratedMeshError.missingNormals(positions.count, normals.count)
        }
        if indices.count % 3 != 0 {
            throw GeneratedMeshError.invalidIndices(indices.count, indices.count % 3)
        }
    }

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

    public enum GeneratedMeshError: LocalizedError {
        case empty
        case missingNormals(_ countPositions: Int, _ countNormals: Int)
        case noIndices
        case invalidIndices(_ count: Int, _ remainder: Int)

        /// A localized message describing what error occurred.
        public var errorDescription: String? {
            switch self {
            case .empty:
                "The meshbuffer doesn't have any normals, vertices."
            case let .missingNormals(pos, norms):
                "The generated buffer is missing normals. There are \(pos) vertices and \(norms) normals recorded."
            case .noIndices:
                "The meshbuffer doesn't have any indices."
            case let .invalidIndices(cnt, remainder):
                "The meshbuffer has in invalid number of indices: \(cnt), which leaves a remainder of \(remainder)"
            }
        }

        /// A localized message describing the reason for the failure.
        public var failureReason: String? { nil }
    }
}
