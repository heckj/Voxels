#if canImport(simd)
    import simd
#endif

public typealias Vector = SIMD3<Float>

public extension Vector {
    static let zero = SIMD3<Float>(0, 0, 0)

    /// Tolerance for determining minimum or nearly-equivalent lengths for vectors.
    ///
    /// The built-in value for this library is `1e-8`.
    static let epsilon = Float.leastNonzeroMagnitude

    /// The length of the vector.
    var length: Float {
        #if canImport(simd)
            return simd.length(self)
        #else
            return dot(self).squareRoot()
        #endif
    }

    /// The square of the length.
    ///
    /// Use `lengthSquared` over `length` if you're able for repeated calculations, because this is a faster computation.
    var lengthSquared: Float {
        #if canImport(simd)
            return simd.length_squared(self)
        #else
            return dot(self)
        #endif
    }

    /// A Boolean value indicating that the length of the vector is `1`.
    var isNormalized: Bool {
        #if canImport(simd)
            abs(simd.length_squared(self) - Float(1.0)) < Vector.epsilon
        #else
            abs(dot(self) - 1) < Vector.epsilon
        #endif
    }

    /// Computes the dot-product of this vector and another you provide.
    /// - Parameter other: The vector against which to compute a dot product.
    /// - Returns: A double that indicates the value to which one vector applies to another.
    func dot(_ another: Vector) -> Float {
        #if canImport(simd)
            return simd.dot(self, another)
        #else
            x * another.x + y * another.y + z * another.z
        #endif
    }

    /// Computes the cross-product of this vector and another you provide.
    /// - Parameter other: The vector against which to compute a cross product.
    /// - Returns: Returns a vector that is orthogonal to the two vectors used to compute the cross product.
    func cross(_ other: Vector) -> Vector {
        #if canImport(simd)
            return simd.cross(self, other)
        #else
            Vector(
                y * other.z - z * other.y,
                z * other.x - x * other.z,
                x * other.y - y * other.x
            )
        #endif
    }

    /// Returns a normalized vector with a length of one.
    func normalized() -> Vector {
        let length = length
        return length == 0 ? .zero : self / length
    }

    /// Linearly interpolate between this vector and another you provide.
    /// - Parameters:
    ///   - a: The vector to interpolate towards.
    ///   - t: A value, typically between `0` and `1`, to indicate the position  to interpolate between the two vectors.
    /// - Returns: A vector interpolated to the position you provide.
    func lerp(_ a: Vector, _ t: Float) -> Vector {
        self + (a - self) * t
    }
    
    /// The squared distance from this vector to another you provide.
    /// - Parameter other: The vector to compare
    /// - Returns: The square of the distance between the vectors
    func distance_squared(_ other: Self) -> Float {
        (self - other).lengthSquared
    }

    /// Returns the vector, rewritten and reflected from x, y, z to y, z, x
    @inline(__always)
    func yzx() -> Self {
        Self(y, z, x)
    }

    /// Returns the vector, rewritten and reflected from x, y, z to z, x, y
    @inline(__always)
    func zxy() -> Self {
        Self(z, x, y)
    }
}
