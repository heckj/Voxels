public class VoxelMeshRenderer {
    /// This stride of the SDF array did not produce a vertex.
    static let NULL_VERTEX = UInt32.max

    /// A fast and simple meshing algorithm that produces a single quad for every visible face of a block.
    public static func fastBlockMeshSurfaceFaces(_ v: some VoxelAccessible, scale: VoxelScale<Float>, within bounds: VoxelBounds) -> MeshBuffer {
        var buffer = MeshBuffer()

        for index in bounds.indices {
            do {
                if try v.isSurface(index) {
                    for face in CubeFace.allCases {
                        if try v.isSurfaceFace(index, direction: face) {
                            buffer.addQuad(index: index, scale: scale, face: face)
                        }
                    }
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }

        return buffer
    }

    public static func fastBlockMesh(_ v: some VoxelAccessible, scale: VoxelScale<Float>, within bounds: VoxelBounds? = nil) -> MeshBuffer {
        let boundsForIndices: VoxelBounds = bounds ?? v.bounds
        var buffer = MeshBuffer()

        for index in boundsForIndices.indices {
            if let voxel = v[index], voxel.isOpaque() {
                for face in CubeFace.allCases {
                    buffer.addQuad(index: index, scale: scale, face: face)
                }
            }
        }

        return buffer
    }

    public static func fastBlockMeshByLayers(_ v: some VoxelAccessible, scale: VoxelScale<Float>) -> [Int: MeshBuffer] {
        var collection: [Int: MeshBuffer] = [:]

        for yIndexValue in v.bounds.min.y ... v.bounds.max.y {
            var buffer = MeshBuffer()
            let layerBounds = VoxelBounds(min: VoxelIndex(v.bounds.min.x, yIndexValue, v.bounds.min.z),
                                          max: VoxelIndex(v.bounds.max.x, yIndexValue, v.bounds.max.z))
            for index in layerBounds.indices {
                if let voxel = v[index], voxel.isOpaque() {
                    for face in CubeFace.allCases {
                        buffer.addQuad(index: index, scale: scale, face: face)
                    }
                }
            }
            if !buffer.indices.isEmpty {
                collection[yIndexValue] = buffer
            }
        }
        return collection
    }
}
