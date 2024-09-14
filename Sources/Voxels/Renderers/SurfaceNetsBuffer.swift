/// The output buffers used by [`surfaceNetMesh`]. These buffers can be reused to avoid reallocating memory.
public struct SurfaceNetsBuffer {
    static let NULL_VERTEX = UInt32.max
    public var meshbuffer: MeshBuffer

    // MARK: the buffers below are for computing the surface nets

    /// Local 3D array coordinates of every voxel that intersects the isosurface.
    public var surface_points: [SIMD3<UInt32>]

    /// Stride of every voxel that intersects the isosurface. Can be used for efficient post-processing.
    var surface_strides: [UInt32]

    /// Used to map back from voxel stride to vertex index.
    var stride_to_index: [UInt32]

    var maybe_make_quad_call_count: Int
    /// Clears all of the buffers, but keeps the memory allocated for reuse.
    mutating func reset(arraySize: UInt) {
        maybe_make_quad_call_count = 0
        meshbuffer.reset()
        surface_points = []
        surface_strides = []
        // Just make sure this buffer is big enough, whether or not we've used it before.
        stride_to_index = Array(repeating: SurfaceNetsBuffer.NULL_VERTEX, count: Int(arraySize))
    }

    init(positions: [SIMD3<Float>], normals: [SIMD3<Float>], indices: [UInt32], surface_points: [SIMD3<UInt32>], surface_strides: [UInt32], stride_to_index: [UInt32]) {
        meshbuffer = MeshBuffer(positions: positions, indices: indices, normals: normals)
        self.surface_points = surface_points
        self.surface_strides = surface_strides
        self.stride_to_index = stride_to_index
        maybe_make_quad_call_count = 0
    }

    init(arraySize: UInt) {
        meshbuffer = MeshBuffer()
        surface_points = []
        surface_strides = []
        stride_to_index = Array(repeating: SurfaceNetsBuffer.NULL_VERTEX, count: Int(arraySize))
        maybe_make_quad_call_count = 0
    }
}
