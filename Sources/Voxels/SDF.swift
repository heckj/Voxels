#if canImport(simd)
    import simd
#endif

public protocol VoxelSampleable {
    associatedtype VoxelDataType where VoxelDataType: SIMDScalar
    func valueAt(x: VoxelDataType, y: VoxelDataType, z: VoxelDataType) -> VoxelDataType
    func valueAt(_ combined: SIMD3<VoxelDataType>) -> VoxelDataType
}

/// wrapper for a signed distance function
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

    #if canImport(simd)
        public static func box(_ b: SIMD3<Float>) -> SDFSampleable<Float> {
            SDFSampleable<Float>() { p in
                let q = abs(p) - b
                return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0)
            }
        }

        public static func framedBox(_ b: SIMD3<Float>, e: Float) -> SDFSampleable<Float> {
            SDFSampleable<Float>() { pExternal in
                let p = abs(pExternal) - b
                let q = abs(p + e) - e
                return min(min(
                    length(max(SIMD3<Float>(p.x, q.y, q.z), 0.0)) + min(max(p.x, max(q.y, q.z)), 0.0),
                    length(max(SIMD3<Float>(q.x, p.y, q.z), 0.0)) + min(max(q.x, max(p.y, q.z)), 0.0)
                ),
                length(max(SIMD3<Float>(q.x, q.y, p.z), 0.0)) + min(max(q.x, max(q.y, p.z)), 0.0))
            }
        }
    #endif
    
    public static func ripple() -> SDFSampleable<Float> {
        SDFSampleable { p in
            2.5 - sqrt(p.x * p.x + p.y * p.y + p.z * p.z)
        }
    }
}
