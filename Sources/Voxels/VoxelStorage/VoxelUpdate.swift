/// A type that represents an update to a single voxel from a collection.
public struct VoxelUpdate<T: Sendable>: Sendable {
    /// The index location of the voxel change.
    public let index: VoxelIndex
    /// The updated voxel value.
    public let value: T

    /// Creates a new update with the index and value you provide.
    /// - Parameters:
    ///   - index: The index location of the voxel change.
    ///   - value: The updated voxel value.
    public init(index: VoxelIndex, value: T) {
        self.index = index
        self.value = value
    }
}
