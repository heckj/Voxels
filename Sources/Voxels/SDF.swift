public protocol SignedDistanceField {
    associatedtype VoxelDataType where VoxelDataType: SIMDScalar
    func valueAt(x: VoxelDataType, y: VoxelDataType, z: VoxelDataType) -> VoxelDataType
    func valueAt(_ combined: SIMD3<VoxelDataType>) -> VoxelDataType
}

/// Signed distance function
public struct SDFWrapper<T: SIMDScalar>: Sendable {
    public let _function: @Sendable (T, T, T) -> T

    public init(_function: @escaping @Sendable (T, T, T) -> T) {
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

/// A collection of signed distance functions
///
/// For more examples, see https://iquilezles.org/articles/distfunctions/
public enum SDF {
    // A signed-distance field of a sphere, radius 0.5.
    public static let sphere = SDFWrapper<Float>() { x, y, z in
        Self._sphere(p: SIMD3<Float>(x, y, z), radius: 0.5)
    }

    static func _sphere(p: SIMD3<Float>, radius: Float) -> Float {
        p.length - radius
    }
    
//    static func _cube(b: Vector, p: Vector) -> Float {
//        let q = p.abs() - b;
//        q.max(Vec3A::ZERO).length() + q.max_element().min(0.0)
//    }

//    static func _link(le: f32, r1: f32, r2: f32, p: Vec3A) -> f32 {
//        let q = Vec3A::new(p.x, (p.y.abs() - le).max(0.0), p.z);
//        Vec2::new(q.length() - r1, q.z).length() - r2
//    }

}
