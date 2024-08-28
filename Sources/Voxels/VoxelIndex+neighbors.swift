public extension VoxelIndex {
    static func manhattan_distance(from: VoxelIndex, to: VoxelIndex) -> Int {
        abs(from.x - to.x) + abs(from.y - to.y) + abs(from.z - to.z)
    }

    enum NeighborStrategy {
        case raw
        case opaque
        case surface
    }

    static func neighbors(distance: Int, origin: VoxelIndex, voxels: any VoxelAccessible, strategy: NeighborStrategy = .raw) throws -> Set<VoxelIndex> {
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
                            if try voxels.isSurface(computedIndex) {
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
