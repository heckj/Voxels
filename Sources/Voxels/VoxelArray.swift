public struct VoxelArray<T>: VoxelAccessible, StrideIndexable {
    var _contents: [T]
    public let edgeSize: Int

    public init(edge: Int, value: T) {
        precondition(edge >= 0)
        edgeSize = edge
        _contents = Array(repeating: value, count: edge * edge * edge)
    }

    public var size: Int {
        _contents.count
    }

    @inlinable
    public func linearize(_ arr: [UInt]) -> Int {
        linearize(arr[0], arr[1], arr[2])
    }

    @inlinable
    public func linearize(_ arr: SIMD3<UInt>) -> Int {
        let index = (Int(arr.x) * edgeSize * edgeSize) + (Int(arr.y) * edgeSize) + Int(arr.z)
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
    public func linearize(_ arr: SIMD3<UInt32>) -> Int {
        let convertedSIMD = SIMD3<UInt>(UInt(arr.x), UInt(arr.y), UInt(arr.z))
        return linearize(convertedSIMD)
    }

    @inlinable
    public func linearize(_ x: UInt, _ y: UInt, _ z: UInt) -> Int {
        linearize(SIMD3<UInt>(x, y, z))
    }

    @inlinable
    public func delinearize(_ strideIndex: Int) -> SIMD3<Int> {
        precondition(strideIndex >= 0)
        let majorStride = edgeSize * edgeSize
        let minorStride = edgeSize
        var x = 0
        if strideIndex > majorStride {
            x = strideIndex / majorStride
        }

        let remaining = strideIndex - (x * majorStride)
        var y = 0
        if remaining > minorStride {
            y = remaining / minorStride
        }

        let z = remaining - (y * minorStride)
        return SIMD3<Int>(x, y, z)
    }

    public func value(x: Int, y: Int, z: Int) -> T? {
        _contents[linearize(UInt(x), UInt(y), UInt(z))]
    }

    public subscript(position: SIMD3<Int>) -> T? {
        get {
            _contents[linearize(UInt(position.x), UInt(position.y), UInt(position.z))]
        }
        set(newValue) {
            let pos = linearize(UInt(position.x), UInt(position.y), UInt(position.z))
            if let newValue {
                _contents[pos] = newValue
            }
        }
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
