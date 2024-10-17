// #if canImport(simd)
//    import simd
// #endif
//
// public extension SIMD2<Float> {
//    func lerp(_ a: SIMD2<Float>, _ t: Float) -> SIMD2<Float> {
//        #if canImport(simd)
//            return simd.mix(self, a, t: t)
//        #else
//            self + (a - self) * t
//        #endif
//    }
// }
