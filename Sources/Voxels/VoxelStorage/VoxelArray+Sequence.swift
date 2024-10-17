extension VoxelArray: Sequence {
    public typealias Iterator = VoxelArrayIterator

    public func makeIterator() -> VoxelArrayIterator {
        VoxelArrayIterator(self)
    }

    public struct VoxelArrayIterator: IteratorProtocol {
        var position: Int
        let originalVoxelArray: VoxelArray<T>

        init(_ originalVoxelArray: VoxelArray<T>) {
            position = -1
            self.originalVoxelArray = originalVoxelArray
        }

        public mutating func next() -> T? {
            if position < originalVoxelArray.bounds.size - 1 {
                position += 1
                return originalVoxelArray[position]
            }
            return nil
        }
    }
}
