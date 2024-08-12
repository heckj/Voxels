public protocol VoxelAccessible<Element> {
    associatedtype Element
    func value(x: Int, y: Int, z: Int) -> Element?
    subscript(_: SIMD3<Int>) -> Element? { get }
}

public protocol StrideIndexable {
    func linearize(_ arr: SIMD3<UInt>) -> Int
    func delinearize(_ arr: Int) -> SIMD3<Int>
}
