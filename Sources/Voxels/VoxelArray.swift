public struct VoxelArray<T>: VoxelAccess {
    var _contents: [T]
    public let edgeSize: Int

    public init(size: UInt, value: T) {
        edgeSize = Int(size)
        _contents = Array(repeating: value, count: Int(size) * Int(size) * Int(size))
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
        linearize(arr.x, arr.y, arr.z)
    }

    @inlinable
    public func linearize(_ arr: SIMD3<UInt32>) -> Int {
        linearize(UInt(arr.x), UInt(arr.y), UInt(arr.z))
    }

    @inlinable
    public func linearize(_ x: UInt, _ y: UInt, _ z: UInt) -> Int {
        let index = (Int(x) * edgeSize * edgeSize) + (Int(y) * edgeSize) + Int(z)
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
    public func delinearize(_ arr: UInt) -> SIMD3<UInt> {
        let majorStride = UInt(edgeSize * edgeSize)
        let minorStride = UInt(edgeSize)
        var x: UInt = 0
        if arr > majorStride {
            x = arr / majorStride
        }

        let remaining = arr - (x * majorStride)
        var y: UInt = 0
        if remaining > minorStride {
            y = remaining / minorStride
        }

        let z = remaining - (y * minorStride)
        return SIMD3<UInt>(x, y, z)
    }

    public func value(x: UInt, y: UInt, z: UInt) -> T {
        _contents[linearize(x, y, z)]
    }
}
