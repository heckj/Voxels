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

    subscript(linearindex: Int) -> T {
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

extension VoxelArray: Collection {
    public func index(after i: VoxelIndex) -> VoxelIndex {
        let linearPosition = bounds._unchecked_linearize(i)
        return bounds._unchecked_delinearize(linearPosition + 1)
    }

    public var startIndex: VoxelIndex {
        bounds._unchecked_delinearize(0)
    }

    public var endIndex: VoxelIndex {
        bounds._unchecked_delinearize(count - 1)
    }

    public subscript(_ index: VoxelIndex) -> T {
        get {
            let linearPosition = bounds._unchecked_linearize(index)
            precondition(linearPosition >= 0 && linearPosition < _contents.count)
            return _contents[linearPosition]
        }
        set(newValue) {
            let linearPosition = bounds._unchecked_linearize(index)
            precondition(linearPosition >= 0 && linearPosition < _contents.count)
            _contents[linearPosition] = newValue
        }
    }
}
