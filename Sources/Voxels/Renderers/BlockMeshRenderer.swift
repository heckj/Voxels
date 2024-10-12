// swiftformat:disable opaqueGenericParameters
import IssueReporting

/// A renderer for creating block 3D meshes of opaque voxels.
public class BlockMeshRenderer {
    public init() {}

    /// Returns a single mesh for the voxels.
    /// - Parameters:
    ///   - v: The voxel collection.
    ///   - scale: The scale to map voxel indices to a floating point coordinate.
    ///   - bounds: The bounds within which to render.
    ///   - surfaceOnly: A Boolean value indicating whether to render only voxels at the "surface".
    ///   - filter: A closure to filter voxels to include in the mesh.
    ///
    /// The surface option returns a mesh with quads for any visible surface.
    /// The alternative creates a quad for every voxel face, regardless of potential visibility.
    public func render<VOXEL: VoxelBlockRenderable>(_ v: any VoxelAccessible<VOXEL>, scale: VoxelScale<Float>, within bounds: VoxelBounds, surfaceOnly: Bool = false, filter: ((VOXEL) -> Bool)? = nil) -> MeshBuffer {
        var buffer = MeshBuffer()

        if surfaceOnly {
            for index in bounds.indices {
                if let filterfunction = filter, let voxel = v[index] {
                    if filterfunction(voxel) == false { continue }
                }

                do {
                    if try v.isSurface(index) {
                        for face in CubeFace.allCases {
                            if try v.isSurfaceFace(index, direction: face) {
                                buffer.addQuad(index: index, scale: scale, face: face)
                            }
                        }
                    }
                } catch {
                    reportIssue(error.localizedDescription)
                    fatalError()
                }
            }
        } else {
            for index in bounds.indices {
                if let voxel = v[index] {
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

    public static func fastBlockMeshByLayers<VOXEL: VoxelBlockRenderable>(_ v: any VoxelAccessible<VOXEL>, scale: VoxelScale<Float>) -> [Int: MeshBuffer] {
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
