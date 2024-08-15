public typealias VoxelIndex = SIMD3<Int>

public extension VoxelIndex {
    init(x: Int, y: Int, z: Int) {
        self.init(x, y, z)
    }

    init(_ tupleIn: (Int, Int, Int)) {
        self.init(tupleIn.0, tupleIn.1, tupleIn.2)
    }
}
