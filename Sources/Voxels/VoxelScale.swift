public struct VoxelScale<T: SIMDScalar> {
    public let origin: SIMD3<T>
    public let cubeSize: T

    /// Creates a new scale from an integer-based voxel domain to an external range.
    ///
    /// This scale presupposes that voxels are cubes.
    ///
    /// - Parameters:
    ///   - origin: The origin location of the initial, corner voxel.
    ///   - cubeSize: The width of a voxel cube.
    public init(origin: SIMD3<T>, cubeSize: T) {
        self.origin = origin
        self.cubeSize = cubeSize
    }

    /// Returns the centroid position in the range output from the voxel index you provide.
    /// - Parameter index: The voxel's index.
    /// - Returns: The position of the center of the voxel.
    public func centroidPosition(_ index: VoxelIndex) -> SIMD3<T> where T: BinaryFloatingPoint {
        cornerPosition(index) + SIMD3<T>(repeating: cubeSize / 2.0)
    }

    /// Returns the inner corner position in the range output from the voxel index you provide.
    /// - Parameter index: The voxel's index.
    /// - Returns: The inner corner (closest to the origin) of the voxel.
    public func cornerPosition(_ index: VoxelIndex) -> SIMD3<T> where T: BinaryFloatingPoint {
        origin + SIMD3<T>(x: T(index.x), y: T(index.y), z: T(index.z)) * cubeSize
    }

    /// Returns the inner corner position in the range output from the voxel index you provide.
    /// - Parameter index: The voxel's index.
    /// - Returns: The inner corner (closest to the origin) of the voxel.
    public func cornerPosition(_ index: VoxelIndex) -> SIMD3<T> where T: FixedWidthInteger {
        SIMD3<T>(x: origin.x + (T(index.x) * cubeSize),
                 y: origin.y + (T(index.y) * cubeSize),
                 z: origin.z + (T(index.z) * cubeSize))
    }

    /// Returns the voxelIndex for the position you provide.
    /// - Parameter position: The position of the point.
    /// - Returns: The index of the voxel that contains that point.
    public func index(for position: SIMD3<T>) -> VoxelIndex where T: BinaryFloatingPoint {
        let x = (Double(position.x) - Double(origin.x)) / Double(cubeSize)
        let y = (Double(position.y) - Double(origin.y)) / Double(cubeSize)
        let z = (Double(position.z) - Double(origin.z)) / Double(cubeSize)
        return VoxelIndex(x: Int(x.rounded(.towardZero)),
                          y: Int(y.rounded(.towardZero)),
                          z: Int(z.rounded(.towardZero)))
    }
}

public extension VoxelScale where T == Float {
    init() {
        origin = SIMD3<Float>(0, 0, 0)
        cubeSize = 1.0
    }
}

public extension VoxelScale where T == Int {
    init() {
        origin = SIMD3<Int>(0, 0, 0)
        cubeSize = 1
    }
}
