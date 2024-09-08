#if canImport(simd)
    import simd
#endif

public extension SIMD2<Float> {
    func lerp(_ a: SIMD2<Float>, _ t: Float) -> SIMD2<Float> {
        #if canImport(simd)
            return simd.mix(self, a, t: t)
        #else
            self + (a - self) * t
        #endif
    }
}

// MORE LERP

/// Determines a normalized offset value for linear interpolation from two values on either side of 0, with 0 being the point to interpolate towards.
/// The provided values are required to have opposite signs (one negative, one positive) in order to use 0 as the marker for the interpolation direction.
/// - Parameters:
///   - f0: The first value.
///   - f1: The second value.
/// - Returns: An offset value between 0 and 1.0 that indicates the relative distance of 0 to the first of the provided points.
public func normalizedOffset(_ f0: Float, _ f1: Float) -> Float {
    let verifiedOppositeSigns = (f0 > 0) != (f1 > 0)
    precondition(verifiedOppositeSigns, "The values being interpolated (\(f0), and \(f1) aren't opposite signs.")
    return (0 - f0) / (f1 - f0)
}
