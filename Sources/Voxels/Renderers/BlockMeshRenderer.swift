// swiftformat:disable opaqueGenericParameters

/// A renderer for creating block 3D meshes of opaque voxels.
public class BlockMeshRenderer {
    /// Creates a block mesh renderer.
    public init() {}

    /// Returns a single mesh for the selected voxels from a collection.
    /// - Parameters:
    ///   - voxels: The voxel collection.
    ///   - scale: The scale to map voxel indices to a floating point coordinate.
    ///   - bounds: The bounds within which to render.
    ///   - surfaceOnly: A Boolean value indicating whether to render only voxels at the "surface".
    ///   - filter: A closure to filter voxels to include in the mesh.
    ///
    /// The surface option returns a mesh with quads for any visible surface.
    /// The alternative creates a quad for every voxel face, regardless of potential visibility.
    public func render<VOXEL: VoxelBlockRenderable>(_ voxels: any VoxelAccessible<VOXEL>, scale: VoxelScale<Float>, within bounds: VoxelBounds, surfaceOnly: Bool = false, filter: ((VOXEL) -> Bool)? = nil) -> MeshBuffer {
        var buffer = MeshBuffer()

        if surfaceOnly {
            for index in bounds.indices {
                if let filterfunction = filter, let voxel = voxels[index] {
                    if filterfunction(voxel) == false { continue }
                }

                do {
                    if voxels.isSurface(index) {
                        for face in CubeFace.allCases {
                            if voxels.isSurfaceFace(index, direction: face) {
                                buffer.addQuad(index: index, scale: scale, face: face)
                            }
                        }
                    }
                }
            }
        } else {
            for index in bounds.indices {
                if let voxel = voxels[index] {
                    if let filterfunction = filter {
                        if filterfunction(voxel) == false { continue }
                    }
                    if voxel.isOpaque() {
                        for face in CubeFace.allCases {
                            buffer.addQuad(index: index, scale: scale, face: face)
                        }
                    }
                }
            }
        }

        return buffer
    }

    /// Returns a collection of mesh buffers, indexed by vertical layer.
    /// - Parameters:
    ///   - voxels: The voxel collection.
    ///   - scale: The scale to map voxel indices to a floating point coordinate.
    public static func fastBlockMeshByLayers<VOXEL: VoxelBlockRenderable>(_ voxels: any VoxelAccessible<VOXEL>, scale: VoxelScale<Float>) -> [Int: MeshBuffer] {
        var collection: [Int: MeshBuffer] = [:]

        for yIndexValue in voxels.bounds.min.y ... voxels.bounds.max.y {
            var buffer = MeshBuffer()
            let layerBounds = VoxelBounds(min: VoxelIndex(voxels.bounds.min.x, yIndexValue, voxels.bounds.min.z),
                                          max: VoxelIndex(voxels.bounds.max.x, yIndexValue, voxels.bounds.max.z))
            for index in layerBounds.indices {
                if let voxel = voxels[index], voxel.isOpaque() {
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
