public protocol SignedDistanceField {
    associatedtype VoxelDataType where VoxelDataType: SIMDScalar
    func valueAt(x: VoxelDataType, y: VoxelDataType, z: VoxelDataType) -> VoxelDataType
    func valueAt(_ combined: SIMD3<VoxelDataType>) -> VoxelDataType
}

/// Signed distance function
public struct SDF<T: SIMDScalar> {
    public let _function: (T, T, T) -> T

    public init(_function: @escaping (T, T, T) -> T) {
        self._function = _function
    }

    @inlinable
    public func valueAt(x: T, y: T, z: T) -> T {
        _function(x, y, z)
    }

    @inlinable
    public func valueAt(_ combined: SIMD3<T>) -> T {
        _function(combined.x, combined.y, combined.z)
    }
}
