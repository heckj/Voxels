public extension VoxelArray {
    mutating func updating(with voxels: VoxelHash<T>) {
        for idx in voxels._contents.keys {
            if let voxelValue = voxels[idx] {
                set(idx, newValue: voxelValue)
            }
        }
    }

    mutating func updating(with voxelUpdates: [VoxelUpdate<T>]) {
        for update in voxelUpdates {
            set(update.index, newValue: update.value)
        }
    }
}
