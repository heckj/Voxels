extension VoxelBounds: Sequence {
    public typealias Iterator = VoxelBoundsIterator

    public func makeIterator() -> VoxelBoundsIterator {
        VoxelBoundsIterator(self)
    }

    public struct VoxelBoundsIterator: IteratorProtocol {
        var position: Int
        let originalVoxelBounds: VoxelBounds

        init(_ originalVoxelBounds: VoxelBounds) {
            position = originalVoxelBounds._unchecked_linearize(originalVoxelBounds.min) - 1
            self.originalVoxelBounds = originalVoxelBounds
        }

        public mutating func next() -> VoxelIndex? {
            if position < originalVoxelBounds.size - 1 {
                position += 1
                return originalVoxelBounds._unchecked_delinearize(position)
            }
            return nil
        }
    }
}
