public struct VoxelArray<T: VoxelRenderable>: VoxelWritable {
    var _contents: [T]
    public let edgeSize: Int
    public var bounds: VoxelBounds

    public var indices: any Sequence<VoxelIndex> {
        (0 ..< bounds.size).map { bounds._unchecked_delinearize($0) }
    }

    public init(edge: Int, value: T) {
        precondition(edge > 0)
        edgeSize = edge
        _contents = Array(repeating: value, count: edge * edge * edge)
        bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(edge - 1, edge - 1, edge - 1))
    }

    public func value(_ vi: VoxelIndex) throws -> T? {
        let stride = try bounds.linearize(vi)
        return _contents[stride]
    }

    public mutating func set(_ vi: VoxelIndex, newValue: T) throws {
        let stride = try bounds.linearize(vi)
        _contents[stride] = newValue
    }

    subscript(index: Int) -> T {
        get {
            precondition(index >= 0 && index < _contents.count)
            return _contents[index]
        }
        set(newValue) {
            precondition(index >= 0 && index < _contents.count)
            _contents[index] = newValue
        }
    }
}

extension VoxelArray: Sequence {
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
