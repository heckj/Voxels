public protocol VoxelSampleable {
    associatedtype VoxelDataType where VoxelDataType: SIMDScalar
    func valueAt(x: VoxelDataType, y: VoxelDataType, z: VoxelDataType) -> VoxelDataType
    func valueAt(_ combined: SIMD3<VoxelDataType>) -> VoxelDataType
}

/// Signed distance function
public struct SDFSampleable<T: SIMDScalar>: Sendable, VoxelSampleable {
    public let _function: @Sendable (SIMD3<T>) -> T

    public init(_function: @escaping @Sendable (SIMD3<T>) -> T) {
        self._function = _function
    }

    @inlinable
    public func valueAt(x: T, y: T, z: T) -> T {
        _function(SIMD3<T>(x, y, z))
    }

    @inlinable
    public func valueAt(_ combined: SIMD3<T>) -> T {
        _function(combined)
    }
}

/// A collection of signed distance functions
///
/// For more examples, see https://iquilezles.org/articles/distfunctions/
public enum SDF {
    // A signed-distance field of a sphere, with a default radius 0.5.
    public static func sphere(radius: Float = 0.5) -> SDFSampleable<Float> {
        SDFSampleable<Float>() { p in
            p.length - radius
        }
    }
}

extension Float: VoxelRenderable {
    public func isOpaque() -> Bool {
        self < 0
    }
}

extension Int: VoxelRenderable {
    public func isOpaque() -> Bool {
        self > 0
    }
}
