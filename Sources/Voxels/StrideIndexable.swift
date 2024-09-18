/// A type that can be accessed with a single, linear location within an array.
public protocol StrideIndexable {
    func linearize(_ arr: VoxelIndex) throws -> Int
    func delinearize(_ arr: Int) throws -> VoxelIndex

    var size: Int { get }
}
