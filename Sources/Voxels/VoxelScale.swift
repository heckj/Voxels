/// A scale that provides a mapping between Voxel coordinates and 3D points.
///
/// Used for sampling data into a voxel data structure, or rendering voxel data into a 3D mesh.
public struct VoxelScale<T: SIMDScalar & Sendable> {
    // TODO(heckj): When FixedSized arrays become a "thing" - switch to that!!
    public let origin: (T, T, T)
    public let cubeSize: T

    /// Creates a new scale from an integer-based voxel domain to an external range.
    ///
    /// This scale presupposes that voxels are cubes.
    ///
    /// - Parameters:
    ///   - origin: The origin location of the initial, corner voxel.
    ///   - cubeSize: The width of a voxel cube.
    public init(origin: SIMD3<T>, cubeSize: T) {
        self.origin = (origin.x, origin.y, origin.z)
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
        let simdOrigin = SIMD3<T>(x: origin.0, y: origin.1, z: origin.2)
        return simdOrigin + SIMD3<T>(x: T(index.x), y: T(index.y), z: T(index.z)) * cubeSize
    }

    /// Returns the inner corner position in the range output from the voxel index you provide.
    /// - Parameter index: The voxel's index.
    /// - Returns: The inner corner (closest to the origin) of the voxel.
    public func cornerPosition(_ index: VoxelIndex) -> SIMD3<T> where T: FixedWidthInteger {
        SIMD3<T>(x: (origin.0 + T(index.x)) * cubeSize,
                 y: (origin.1 + T(index.y)) * cubeSize,
                 z: (origin.2 + T(index.z)) * cubeSize)
    }

    /// Returns the voxelIndex for the position you provide.
    /// - Parameter position: The position of the point.
    /// - Returns: The index of the voxel that contains that point.
    public func index(for position: SIMD3<T>) -> VoxelIndex where T: BinaryFloatingPoint {
        let x = (Double(position.x) - Double(origin.0)) / Double(cubeSize)
        let y = (Double(position.y) - Double(origin.1)) / Double(cubeSize)
        let z = (Double(position.z) - Double(origin.2)) / Double(cubeSize)
        return VoxelIndex(x: Int(x.rounded(.towardZero)),
                          y: Int(y.rounded(.towardZero)),
                          z: Int(z.rounded(.towardZero)))
    }
}

extension VoxelScale: Sendable {}

public extension VoxelScale where T == Float {
    init() {
        origin = (0, 0, 0)
        cubeSize = 1.0
    }

    init(origin: SIMD3<Float>? = nil, cubeSize: Float? = nil) {
        self.origin = (origin?.x ?? 0, origin?.y ?? 0, origin?.z ?? 0)
        self.cubeSize = cubeSize ?? 1.0
    }
}

public extension VoxelScale where T == Int {
    init() {
        origin = (0, 0, 0)
        cubeSize = 1
    }
}
