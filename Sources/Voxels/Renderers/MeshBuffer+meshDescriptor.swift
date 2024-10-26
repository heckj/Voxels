#if canImport(RealityKit)
    public import RealityKit

    public extension MeshBuffer {
        /// Returns a RealityKit mesh descriptor instance for this buffer, if the buffer data is valid.
        func meshDescriptor() -> MeshDescriptor? {
            if indices.isEmpty || positions.isEmpty || normals.isEmpty { return nil }
            var meshDescriptor = MeshDescriptor()
            meshDescriptor.primitives = .triangles(indices)
            meshDescriptor.positions = MeshBuffers.Positions(positions)
            meshDescriptor.normals = MeshBuffers.Normals(normals)
            return meshDescriptor
        }
    }
#endif
