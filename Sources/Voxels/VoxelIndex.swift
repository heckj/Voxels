public struct VoxelIndex: Hashable, Equatable, Sendable {
    let _storage: SIMD3<Int>
    public var x: Int {
        _storage.x
    }

    public var y: Int {
        _storage.y
    }

    public var z: Int {
        _storage.z
    }

    public init() {
        _storage = SIMD3<Int>()
    }

    public init(_ x: Int, _ y: Int, _ z: Int) {
        _storage = SIMD3<Int>(x: x, y: y, z: z)
    }

    public init(x: Int, y: Int, z: Int) {
        _storage = SIMD3<Int>(x: x, y: y, z: z)
    }

    public init(_ tupleIn: (Int, Int, Int)) {
        self.init(x: tupleIn.0, y: tupleIn.1, z: tupleIn.2)
    }

    public init(_ arr: [Int]) {
        precondition(arr.count == 3)
        _storage = SIMD3<Int>(arr)
    }

    @inline(__always)
    public func adding(_ i: Self) -> VoxelIndex {
        VoxelIndex(x: _storage.x + i.x, y: _storage.y + i.y, z: _storage.z + i.z)
    }
}

extension VoxelIndex: ExpressibleByArrayLiteral {
    public init(arrayLiteral scalars: Int...) {
        _storage = SIMD3<Int>(scalars)
    }
}

extension VoxelIndex: Comparable {
    @inlinable
    public static func < (lhs: VoxelIndex, rhs: VoxelIndex) -> Bool {
        lhs.x < rhs.x || lhs.y < rhs.y || lhs.z < rhs.z
    }
}
