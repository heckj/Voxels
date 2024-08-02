
/// The output buffers used by [`surface_nets`]. These buffers can be reused to avoid reallocating memory.
public struct SurfaceNetsBuffer {
    /// The triangle mesh positions.
    ///
    /// These are in array-local coordinates. That is, at the array position `(x, y, z)`, the vertex
    /// position would be `(x, y, z) + centroid` if the isosurface intersects that voxel.
    public var positions: [SIMD3<Float>]

    /// The triangle mesh normals.
    ///
    /// The normals are **not** normalized, since that is done most efficiently on the GPU.
    public var normals: [SIMD3<Float>]

    /// The triangle mesh indices.
    public var indices: [UInt32]

    /// Local 3D array coordinates of every voxel that intersects the isosurface.
    public var surface_points: [SIMD3<UInt32>]

    /// Stride of every voxel that intersects the isosurface. Can be used for efficient post-processing.
    var surface_strides: [UInt32]

    /// Used to map back from voxel stride to vertex index.
    var stride_to_index: [UInt32]

    /// Clears all of the buffers, but keeps the memory allocated for reuse.
    mutating func reset(arraySize: UInt) {
        positions = []
        normals = []
        indices = []
        surface_points = []
        surface_strides = []
        // Just make sure this buffer is big enough, whether or not we've used it before.
        stride_to_index = Array(repeating: NULL_VERTEX, count: Int(arraySize))
    }

    init(positions: [SIMD3<Float>], normals: [SIMD3<Float>], indices: [UInt32], surface_points: [SIMD3<UInt32>], surface_strides: [UInt32], stride_to_index: [UInt32]) {
        self.positions = positions
        self.normals = normals
        self.indices = indices
        self.surface_points = surface_points
        self.surface_strides = surface_strides
        self.stride_to_index = stride_to_index
    }

    init(arraySize: UInt) {
        positions = []
        normals = []
        indices = []
        surface_points = []
        surface_strides = []
        stride_to_index = Array(repeating: NULL_VERTEX, count: Int(arraySize))
    }
}
