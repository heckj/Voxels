public protocol SignedDistanceField {
    var isNegative: Bool { get }
}

/// Signed distance function
struct SDF<T: SIMDScalar> {
    let _function: (T, T, T) -> T

    init(_function: @escaping (T, T, T) -> T) {
        self._function = _function
    }

    @inlinable
    func valueAt(x: T, y: T, z: T) -> T {
        _function(x, y, z)
    }

    @inlinable
    func valueAt(_ combined: SIMD3<T>) -> T {
        _function(combined.x, combined.y, combined.z)
    }
}
