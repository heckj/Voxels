public typealias VoxelIndex = SIMD3<Int>

public extension VoxelIndex {
    init(x: Int, y: Int, z: Int) {
        self.init(x, y, z)
    }

    init(_ tupleIn: (Int, Int, Int)) {
        self.init(tupleIn.0, tupleIn.1, tupleIn.2)
    }

    @inlinable
    func adding(_ i: Self) -> VoxelIndex {
        VoxelIndex(x + i.x, y + i.y, z + i.z)
    }
}

extension VoxelIndex: Comparable {
    @inlinable
    public static func < (lhs: SIMD3<Scalar>, rhs: SIMD3<Scalar>) -> Bool {
        lhs.x < rhs.x || lhs.y < rhs.y || lhs.z < rhs.z
    }
}
