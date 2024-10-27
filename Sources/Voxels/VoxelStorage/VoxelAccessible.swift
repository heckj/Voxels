/// A type that holds a collection of voxels.
public protocol VoxelAccessible<Element>: Collection {
    /// Returns the voxel at the index you provide.
    /// - Parameter : The voxel index
    /// - Returns: The voxel contents, or an error if outside of index bounds.
    func value(_: VoxelIndex) throws -> Element?
    /// The bounds of the voxel collection.
    var bounds: VoxelBounds { get }
    /// Accesses the voxel at the index you provide.
    subscript(_: VoxelIndex) -> Element? { get }
}

/// A type that holds an updatable collection of voxels.
public protocol VoxelWritable<Element>: VoxelAccessible {
    /// Sets the voxel at the index you provide.
    /// - Parameters:
    ///  - newValue: The voxel value.
    ///  - _: The voxel index.
    mutating func set(_: VoxelIndex, newValue: Element) throws
    /// Accesses the voxel at the index you provide.
    subscript(_: VoxelIndex) -> Element? { get set }
}
