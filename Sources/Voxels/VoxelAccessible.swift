public protocol VoxelAccessible {
    associatedtype Element
    func value(x: UInt, y: UInt, z: UInt) -> Element
}

public protocol StrideIndexable {
    func linearize(_ arr: SIMD3<UInt>) -> Int
    func delinearize(_ arr: Int) -> SIMD3<UInt>
}
