import IssueReporting

/// A renderer for creating block 3D meshes of opaque voxels.
public class BlockMeshRenderer {
    public init() {}

    /// A fast and simple meshing algorithm that produces a single quad for every visible face of a block.
    // swiftformat:disable opaqueGenericParameters
    public func render<VOXEL: VoxelBlockRenderable>(_ v: any VoxelAccessible<VOXEL>, scale: VoxelScale<Float>, within bounds: VoxelBounds, surfaceOnly: Bool = false) -> MeshBuffer {
        var buffer = MeshBuffer()

        if surfaceOnly {
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
                    reportIssue(error.localizedDescription)
                    fatalError()
                }
            }
        } else {
            for index in bounds.indices {
                if let voxel = v[index], voxel.isOpaque() {
                    for face in CubeFace.allCases {
                        buffer.addQuad(index: index, scale: scale, face: face)
                    }
                }
            }
        }

        return buffer
    }

    // swiftformat:disable opaqueGenericParameters
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
