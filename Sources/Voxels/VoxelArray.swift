public struct VoxelArray<T: VoxelRenderable>: VoxelWritable, StrideIndexable {
    var _contents: [T]
    public let edgeSize: Int
    public var bounds: VoxelBounds?

    public init(edge: Int, value: T) {
        precondition(edge > 0)
        edgeSize = edge
        _contents = Array(repeating: value, count: edge * edge * edge)
        bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(edge - 1, edge - 1, edge - 1))
    }

    public var size: Int {
        _contents.count
    }

    @inlinable
    public func linearize(_ vi: VoxelIndex) throws -> Int {
        guard let bounds else { fatalError("bounds unset on VoxelArray") }
        if !bounds.contains(vi) {
            throw VoxelAccessError.outOfBounds("Index out of bounds: \(vi)")
        }
        let index = (Int(vi.x) * edgeSize * edgeSize) + (Int(vi.y) * edgeSize) + Int(vi.z)
        // Row-major address by index:
        //
        //    Address of A[i][j][k] = B + W *(P* N * (i-x) + P*(j-y) + (k-z))
        //
        //    Here:
        //
        //    B = Base Address (start address)                             = 0
        //    W = Weight (storage size of one element stored in the array) = 1
        //    M = Row (total number of rows)                               = size
        //    N = Column (total number of columns)                         = size
        //    P = Width (total number of cells depth-wise)                 = size
        //    x = Lower Bound of Row                                       = 0
        //    y = Lower Bound of Column                                    = 0
        //    z = Lower Bound of Width                                     = 0
        return index
    }

    @inlinable
    public func delinearize(_ strideIndex: Int) throws -> VoxelIndex {
        if strideIndex < 0 || strideIndex >= edgeSize * edgeSize * edgeSize {
            throw VoxelAccessError.outOfBounds("stride index out of bounds: \(strideIndex)")
        }

        let majorStride = edgeSize * edgeSize
        let minorStride = edgeSize
        var x = 0
        if strideIndex >= majorStride {
            x = strideIndex / majorStride
        }

        let remaining = strideIndex - (x * majorStride)
        var y = 0
        if remaining >= minorStride {
            y = remaining / minorStride
        }

        let z = remaining - (y * minorStride)
        return VoxelIndex(x, y, z)
    }

    public func value(_ vi: VoxelIndex) throws -> T? {
        let stride = try linearize(vi)
        return _contents[stride]
    }

    public mutating func set(_ vi: VoxelIndex, newValue: T) throws {
        let stride = try linearize(vi)
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
            if position < originalVoxelArray.size - 1 {
                position += 1
                return originalVoxelArray[position]
            }
            return nil
        }
    }
}
