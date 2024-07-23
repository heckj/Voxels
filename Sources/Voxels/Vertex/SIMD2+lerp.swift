public extension SIMD2<Float> {
    func lerp(_ a: SIMD2<Float>, _ t: Float) -> SIMD2<Float> {
        self + (a - self) * t
    }
}
