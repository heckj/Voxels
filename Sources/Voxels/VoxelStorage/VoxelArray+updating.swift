public extension VoxelArray {
    mutating func updating(with voxels: VoxelHash<T>) throws {
        for idx in voxels._contents.keys {
            if let voxelValue = voxels[idx] {
                try set(idx, newValue: voxelValue)
            }
        }
    }

    mutating func updating(with voxelUpdates: [VoxelUpdate<T>]) throws {
        for update in voxelUpdates {
            try set(update.index, newValue: update.value)
        }
    }
}
