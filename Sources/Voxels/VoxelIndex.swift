/// The coordinates of a voxel location.
public struct VoxelIndex: Hashable, Equatable, Sendable {
    let _storage: SIMD3<Int>
    /// The X coordinate.
    public var x: Int {
        _storage.x
    }

    /// The Y coordinate.
    public var y: Int {
        _storage.y
    }

    /// The Z coordinate.
    public var z: Int {
        _storage.z
    }

    public init() {
        _storage = SIMD3<Int>(0, 0, 0)
    }

    /// Creates a new index
    /// - Parameters:
    ///   - x: The X coordinate.
    ///   - y: The Y coordinate.
    ///   - z: The Z coordinate.
    public init(_ x: Int, _ y: Int, _ z: Int) {
        _storage = SIMD3<Int>(x: x, y: y, z: z)
    }

    /// Creates a new index
    /// - Parameters:
    ///   - x: The X coordinate.
    ///   - y: The Y coordinate.
    ///   - z: The Z coordinate.
    public init(x: Int, y: Int, z: Int) {
        _storage = SIMD3<Int>(x: x, y: y, z: z)
    }

    /// Creates a new index from a tuple of three integers.
    /// - Parameter tupleIn: The tuple of three integers that represent the index.
    public init(_ tupleIn: (Int, Int, Int)) {
        self.init(x: tupleIn.0, y: tupleIn.1, z: tupleIn.2)
    }

    /// Creates a new index from an array of integers.
    /// - Parameter arr: The array of integers that represent the index.
    ///
    /// The array is expected to always be 3 integers long. Other lengths will throw an error.
    public init(_ arr: [Int]) {
        precondition(arr.count == 3, "The count of integers for initializing VoxelIndex must be 3")
        _storage = SIMD3<Int>(arr)
    }

    /// Returns a new voxel index that is the component sum of the current index and the index you provide.
    /// - Parameter i: The index to add.
    @inline(__always)
    public func adding(_ i: Self) -> VoxelIndex {
        VoxelIndex(x: _storage.x + i.x, y: _storage.y + i.y, z: _storage.z + i.z)
    }

    /// Returns a new voxel index offset from the current by the axis-aligned index values you provide.
    /// - Parameters:
    ///   - x: The distance in the X direction.
    ///   - y: The distance in the Y direction.
    ///   - z: The distance in the Z direction.
    ///
    /// A convenience function for shifting a `VoxelIndex` so that you don't have to create a new relative
    /// `VoxelIndex` to use with ``adding(_:)``.
    @inline(__always)
    public func adding(_ x: Int, _ y: Int, _ z: Int) -> VoxelIndex {
        VoxelIndex(x: _storage.x + x, y: _storage.y + y, z: _storage.z + z)
    }

    /// Returns a new voxel index offset from the current by the axis-aligned index values you provide.
    /// - Parameters:
    ///   - x: The distance in the X direction.
    ///   - y: The distance in the Y direction.
    ///   - z: The distance in the Z direction.
    ///
    /// A convenience function for shifting a `VoxelIndex` so that you don't have to create a new relative
    /// `VoxelIndex` to use with ``adding(_:)``.
    @inline(__always)
    public func adding(x: Int = 0, y: Int = 0, z: Int = 0) -> VoxelIndex {
        VoxelIndex(x: _storage.x + x, y: _storage.y + y, z: _storage.z + z)
    }

    /// Returns a new voxel index that is the component difference of the current index and the index you provide.
    /// - Parameter i: The index to add.
    @inline(__always)
    public func subtracting(_ i: Self) -> VoxelIndex {
        VoxelIndex(x: _storage.x - i.x, y: _storage.y - i.y, z: _storage.z - i.z)
    }

    /// An index at the position (1, 1, 1)
    @inlinable
    public static var one: VoxelIndex {
        VoxelIndex(1, 1, 1)
    }

    /// An index at the position (0, 0, 0)
    @inlinable
    public static var zero: VoxelIndex {
        VoxelIndex()
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

extension VoxelIndex: CustomStringConvertible {
    public var description: String {
        "[\(x), \(y), \(z)]"
    }
}

extension VoxelIndex: Identifiable {
    public var id: String {
        description
    }
}
