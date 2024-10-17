extension VoxelArray: Collection {
    public typealias Index = Int

    public func index(after i: Int) -> Int {
        i + 1
    }

    public var startIndex: Int {
        0
    }

    public var endIndex: Int {
        _contents.count - 1
    }

    public subscript(linearindex: Int) -> T {
        get {
            precondition(linearindex >= 0 && linearindex < _contents.count)
            return _contents[linearindex]
        }
        set(newValue) {
            precondition(linearindex >= 0 && linearindex < _contents.count)
            _contents[linearindex] = newValue
        }
    }
}
