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
            for index in bounds {
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
            for index in bounds {
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

    public static func renderFramedVoxel(idx: VoxelIndex, scale: VoxelScale<Float>, inset: Float) -> MeshBuffer {
        var buffer = MeshBuffer()
        assert(inset < scale.cubeSize)
        // +----------------------+
        // |\                    /|
        // | \__________________/ |
        // |  |                |  |
        // |  |                |  |

        /// The points of the Quad, viewed face-front, are 'wound' in the following order (1,2,3,4):
        ///  ```
        ///  v1  v3
        ///   | /|
        ///   |/ |
        ///  v2  v4
        /// ```
        ///
        /// negative face ordering (2,1,4,3):
        ///  ```
        ///  v1  v3
        ///   |\ |
        ///   | \|
        ///  v2  v4
        /// ```
        let sOne = scale.cubeSize
        let faces: [CubeFace: [SIMD3<Float>]] = [
            .y: [ // aka "top", order viewed when looking "in"
                [0, sOne, 0], [inset, sOne, inset], [sOne, sOne, 0], [sOne - inset, sOne, inset],
                [0, sOne, 0], [0, sOne, sOne], [inset, sOne, inset], [inset, sOne, sOne - inset],
                [inset, sOne, sOne - inset], [0, sOne, sOne], [sOne - inset, sOne, sOne - inset], [sOne, sOne, sOne],
                [sOne - inset, sOne, inset], [sOne - inset, sOne, sOne - inset], [sOne, sOne, 0], [sOne, sOne, sOne],
            ],
            .yneg: [ // "bottom", order viewed when looking "in"
                [inset, 0, inset], [0, 0, 0], [sOne - inset, 0, inset], [sOne, 0, 0],
                [0, 0, sOne], [0, 0, 0], [inset, 0, sOne - inset], [inset, 0, inset],
                [0, 0, sOne], [inset, 0, sOne - inset], [sOne, 0, sOne], [sOne - inset, 0, sOne - inset],
                [sOne - inset, 0, sOne - inset], [sOne - inset, 0, inset], [sOne, 0, sOne], [sOne, 0, 0],
            ],
            .x: [ // "right", order viewed when looking "in"
                [sOne, 0, 0], [sOne, sOne, 0], [sOne, inset, inset], [sOne, sOne - inset, inset],
                [sOne, sOne - inset, inset], [sOne, sOne, 0], [sOne, sOne - inset, sOne - inset], [sOne, sOne, sOne],
                [sOne, 0, 0], [sOne, inset, inset], [sOne, 0, sOne], [sOne, inset, sOne - inset],
                [sOne, inset, sOne - inset], [sOne, sOne - inset, sOne - inset], [sOne, 0, sOne], [sOne, sOne, sOne],
            ],
            .xneg: [ // "left", order viewed when looking "in"
                [0, sOne, 0], [0, 0, 0], [0, sOne - inset, inset], [0, inset, inset],
                [0, sOne, 0], [0, sOne - inset, inset], [0, sOne, sOne], [0, sOne - inset, sOne - inset],
                [0, inset, inset], [0, 0, 0], [0, inset, sOne - inset], [0, 0, sOne],
                [0, sOne - inset, sOne - inset], [0, inset, sOne - inset], [0, sOne, sOne], [0, 0, sOne],
            ],
            .z: [ // "front", order viewed when looking "in"
                [0, sOne, sOne], [inset, sOne - inset, sOne], [sOne, sOne, sOne], [sOne - inset, sOne - inset, sOne],
                [0, sOne, sOne], [0, 0, sOne], [inset, sOne - inset, sOne], [inset, inset, sOne],
                [inset, inset, sOne], [0, 0, sOne], [sOne - inset, inset, sOne], [sOne, 0, sOne],
                [sOne - inset, sOne - inset, sOne], [sOne - inset, inset, sOne], [sOne, sOne, sOne], [sOne, 0, sOne],
            ],
            .zneg: [ // "back", order viewed when looking "in"
                [inset, sOne - inset, 0], [0, sOne, 0], [sOne - inset, sOne - inset, 0], [sOne, sOne, 0],
                [0, 0, 0], [0, sOne, 0], [inset, inset, 0], [inset, sOne - inset, 0],
                [0, 0, 0], [inset, inset, 0], [sOne, 0, 0], [sOne - inset, inset, 0],
                [sOne - inset, inset, 0], [sOne - inset, sOne - inset, 0], [sOne, 0, 0], [sOne, sOne, 0],
            ],
        ]

        for face in faces.keys {
            guard let quadSet = faces[face] else { continue }
            assert(quadSet.count == 16)
            // translate by index
            let translated = quadSet.map { pt in
                pt + scale.cornerPosition(idx)
            }
            buffer.addQuadPoints(p1: translated[0], p2: translated[1], p3: translated[2], p4: translated[3])
            buffer.addQuadPoints(p1: translated[4], p2: translated[5], p3: translated[6], p4: translated[7])
            buffer.addQuadPoints(p1: translated[8], p2: translated[9], p3: translated[10], p4: translated[11])
            buffer.addQuadPoints(p1: translated[12], p2: translated[13], p3: translated[14], p4: translated[15])
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
            for index in layerBounds {
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
