/// A type that holds a collection of voxels.
public protocol VoxelAccessible<Element>: Collection {
    func value(_: VoxelIndex) throws -> Element?
    var bounds: VoxelBounds { get }

    var indices: [VoxelIndex] { get }
    subscript(_: VoxelIndex) -> Element? { get set }
}

/// A type that holds an updatable collection of voxels.
public protocol VoxelWritable<Element>: VoxelAccessible {
    mutating func set(_: VoxelIndex, newValue: Element) throws
}
