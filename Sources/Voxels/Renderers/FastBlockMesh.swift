public extension VoxelMeshRenderer {
    /// A fast and simple meshing algorithm that produces a single quad for every visible face of a block.
    static func fastBlockMeshSurfaceFaces(_ v: some VoxelAccessible, scale: VoxelScale<Float>) -> MeshBuffer {
        var buffer = MeshBuffer()

        for index in v.indices {
            do {
                if try v.isSurface(index) {
                    for face in CubeFace.allCases {
                        if try v.isSurfaceFace(index, direction: face) {
                            buffer.addQuad(index: index, scale: scale, face: face)
                        }
                    }
                }
            } catch {}
        }

        return buffer
    }

    static func fastBlockMesh(_ v: some VoxelAccessible, scale: VoxelScale<Float>) -> MeshBuffer {
        var buffer = MeshBuffer()

        for index in v.indices {
            if let voxel = v[index], voxel.isOpaque() {
                for face in CubeFace.allCases {
                    buffer.addQuad(index: index, scale: scale, face: face)
                }
            }
        }

        return buffer
    }
}
