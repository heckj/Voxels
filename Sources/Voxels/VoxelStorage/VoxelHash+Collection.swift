extension VoxelHash: Collection {
    public typealias Index = Dictionary<VoxelIndex, T>.Index

    public var startIndex: Dictionary<VoxelIndex, T>.Index {
        _contents.startIndex
    }

    public var endIndex: Dictionary<VoxelIndex, T>.Index {
        _contents.endIndex
    }

    public func index(after: Dictionary<VoxelIndex, T>.Index) -> Dictionary<VoxelIndex, T>.Index {
        _contents.index(after: after)
    }

    public subscript(position: Dictionary<VoxelIndex, T>.Index) -> T {
        let foo: (key: VoxelIndex, value: T) = _contents[position]
        return foo.value
    }
}
