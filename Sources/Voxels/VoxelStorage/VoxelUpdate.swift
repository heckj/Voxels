public struct VoxelUpdate<T: Sendable>: Sendable {
    public let index: VoxelIndex
    public let value: T

    public init(index: VoxelIndex, value: T) {
        self.index = index
        self.value = value
    }
}
