struct VoxelArray<T> {
    var _contents: [T]
    let size: Int

    public init(size: UInt, value: T) {
        self.size = Int(size)
        _contents = Array(repeating: value, count: Int(size) * Int(size) * Int(size))
    }

    @inlinable
    func indexFrom(_ x: UInt, _ y: UInt, _ z: UInt) -> Int {
        let index = (Int(x) * size * size) + (Int(y) * size) + Int(z)
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

    public func value(x: UInt, y: UInt, z: UInt) -> T {
        _contents[indexFrom(x, y, z)]
    }
}