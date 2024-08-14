#if canImport(RealityKit)
    public import RealityKit

    public extension SurfaceNetsBuffer {
        func meshDescriptor() -> MeshDescriptor {
            var meshDescriptor = MeshDescriptor()
            meshDescriptor.primitives = .triangles(indices)
            meshDescriptor.positions = MeshBuffers.Positions(positions)
            meshDescriptor.normals = MeshBuffers.Normals(normals)
            return meshDescriptor
        }
    }

    public extension MeshBuffer {
        func meshDescriptor() -> MeshDescriptor {
            var meshDescriptor = MeshDescriptor()
            meshDescriptor.primitives = .triangles(indices)
            meshDescriptor.positions = MeshBuffers.Positions(positions)
            meshDescriptor.normals = MeshBuffers.Normals(normals)
            return meshDescriptor
        }
    }
#endif
