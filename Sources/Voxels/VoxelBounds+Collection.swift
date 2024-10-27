extension VoxelBounds: Collection {
    public typealias Index = Int

    public func index(after i: Int) -> Int {
        i + 1
    }

    public var startIndex: Int {
        0
    }

    public var endIndex: Int {
        size
    }

    public subscript(_ index: Int) -> VoxelIndex {
        _unchecked_delinearize(index)
    }
}
