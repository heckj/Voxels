public extension VoxelHash {
    mutating func updating(with voxels: VoxelHash<T>) {
        for idx in voxels._contents.keys {
            self[idx] = voxels[idx]
        }
    }

    mutating func updating(with voxelUpdates: [VoxelUpdate<T>]) {
        for update in voxelUpdates {
            self[update.index] = update.value
        }
    }

    func updates() -> [VoxelUpdate<T>] {
        var updates = [VoxelUpdate<T>]()
        for index in _contents.keys.sorted() {
            if let value = self[index] {
                updates.append(.init(index: index, value: value))
            }
        }
        return updates
    }
}
