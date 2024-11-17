public extension VoxelIndex {
    /// Returns the manhattan neighbors with a distance of one from this index.
    @inlinable
    func manhattan_1_neighbors() -> [VoxelIndex] {
        [
            adding(VoxelIndex(1, 0, 0)),
            adding(VoxelIndex(-1, 0, 0)),
            adding(VoxelIndex(0, 1, 0)),
            adding(VoxelIndex(0, -1, 0)),
            adding(VoxelIndex(0, 0, 1)),
            adding(VoxelIndex(0, 0, -1)),
        ]
    }

    /// Returns the manhattan neighbors with a distance of two from this index.
    @inlinable
    func manhattan_2_neighbors() -> [VoxelIndex] {
        var neighbors: [VoxelIndex] = []
        for i in x - 1 ... x + 1 {
            for j in y - 1 ... y + 1 {
                for k in z - 1 ... z + 1 {
                    let new = VoxelIndex(i, j, k)
                    let distance = VoxelIndex.manhattan_distance(from: self, to: new)
                    if distance == 1 || distance == 2 {
                        neighbors.append(new)
                    }
                }
            }
        }
        neighbors.append(adding(VoxelIndex(2, 0, 0)))
        neighbors.append(adding(VoxelIndex(-2, 0, 0)))
        neighbors.append(adding(VoxelIndex(0, 2, 0)))
        neighbors.append(adding(VoxelIndex(0, -2, 0)))
        neighbors.append(adding(VoxelIndex(0, 0, 2)))
        neighbors.append(adding(VoxelIndex(0, 0, -2)))
        return neighbors
    }

    static func manhattan_distance(from: VoxelIndex, to: VoxelIndex) -> Int {
        abs(from.x - to.x) + abs(from.y - to.y) + abs(from.z - to.z)
    }

    enum NeighborStrategy {
        case raw
        case opaque
        case surface
    }

    // swiftformat:disable opaqueGenericParameters
    static func neighbors<VOXEL: VoxelBlockRenderable>(distance: Int, origin: VoxelIndex, voxels: any VoxelAccessible<VOXEL>, strategy: NeighborStrategy = .raw) throws -> Set<VoxelIndex> {
        precondition(distance >= 0)
        var indices: Set<VoxelIndex> = [origin]

        for i in origin.x - distance ... origin.x + distance {
            for j in origin.y - distance ... origin.y + distance {
                for k in origin.z - distance ... origin.z + distance {
                    let computedIndex = VoxelIndex(i, j, k)
                    if manhattan_distance(from: origin, to: computedIndex) <= distance {
                        switch strategy {
                        case .raw:
                            indices.insert(computedIndex)
                        case .opaque:
                            if let voxelData = try voxels.value(computedIndex), voxelData.isOpaque() {
                                indices.insert(computedIndex)
                            }
                        case .surface:
                            if voxels.isSurface(computedIndex) {
                                indices.insert(computedIndex)
                            }
                        }
                    }
                }
            }
        }
        return indices
    }
}
