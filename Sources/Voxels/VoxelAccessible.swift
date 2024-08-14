public protocol VoxelAccessible<Element> {
    associatedtype Element: VoxelRenderable
    func value(x: Int, y: Int, z: Int) throws -> Element?
    subscript(_: SIMD3<Int>) -> Element? { get }

    func isSurface(x: Int, y: Int, z: Int) throws -> Bool
}

public extension VoxelAccessible {
    func isSurface(x: Int, y: Int, z: Int) throws -> Bool {
        if x < 1 || y < 1 || z < 1 {
            throw VoxelAccessError.outOfBounds("Out of Bounds [\(x), \(y), \(z)]")
        }
        guard let voxel = try value(x: x, y: y, z: z), voxel.isOpaque() else {
            return false
        }

        let distance1neighbors = [
            SIMD3<Int>(0, 0, 1),
            SIMD3<Int>(0, 0, -1),
            SIMD3<Int>(0, 1, 0),
            SIMD3<Int>(0, -1, 0),
            SIMD3<Int>(1, 0, 0),
            SIMD3<Int>(-1, 0, 0),
        ]

        let sumOpaqueNeighbors = try distance1neighbors.reduce(into: 0) { partialResult, locationOffset in
            if let voxel = try self.value(x: x + locationOffset.x, y: y + locationOffset.y, z: z + locationOffset.z), voxel.isOpaque() {
                partialResult += 1
            }
        }
        return sumOpaqueNeighbors != 6
    }
}

public protocol VoxelRenderable {
    func isOpaque() -> Bool
    // consider adding a color type here?
}

public protocol StrideIndexable {
    func linearize(_ arr: SIMD3<UInt>) -> Int
    func delinearize(_ arr: Int) -> SIMD3<Int>
}
