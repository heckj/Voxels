extension VoxelHash: Sequence {
    public typealias Iterator = VoxelHashIndexIterator
    public func makeIterator() -> VoxelHashIndexIterator {
        VoxelHashIndexIterator(self)
    }

    public struct VoxelHashIndexIterator: IteratorProtocol {
        var indexPosition: Dictionary<VoxelIndex, T>.Index
        let originalVoxelHash: VoxelHash<T>

        init(_ originalVoxelHash: VoxelHash<T>) {
            self.originalVoxelHash = originalVoxelHash
            indexPosition = self.originalVoxelHash._contents.startIndex
        }

        public mutating func next() -> T? {
            if indexPosition < originalVoxelHash._contents.endIndex {
                let foo: (key: VoxelIndex, value: T) = originalVoxelHash._contents[indexPosition]
                indexPosition = originalVoxelHash._contents.index(after: indexPosition)
                return foo.value
            } else {
                return nil
            }
        }
    }
}
