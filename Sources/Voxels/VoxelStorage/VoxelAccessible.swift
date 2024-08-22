
public protocol VoxelAccessible<Element>: Sequence where Element: VoxelRenderable {
    func value(_: VoxelIndex) throws -> Element?
    var bounds: VoxelBounds { get }
    var indices: any Sequence<VoxelIndex> { get }

    func isSurface(_: VoxelIndex) throws -> Bool
}

public protocol VoxelWritable<Element>: VoxelAccessible {
    mutating func set(_: VoxelIndex, newValue: Element) throws -> Void
}

public extension VoxelAccessible {
    func isSurface(_ tuple: (Int, Int, Int)) throws -> Bool {
        try isSurface(VoxelIndex(tuple))
    }

    func isSurface(_ vindex: VoxelIndex) throws -> Bool {
        if vindex.x < 1 || vindex.y < 1 || vindex.z < 1 {
            throw VoxelAccessError.outOfBounds("Out of Bounds [\(vindex.x), \(vindex.y), \(vindex.z)]")
        }
        guard let voxel = try value(vindex), voxel.isOpaque() else {
            return false
        }

        let distance1neighbors = [
            VoxelIndex(0, 0, 1),
            VoxelIndex(0, 0, -1),
            VoxelIndex(0, 1, 0),
            VoxelIndex(0, -1, 0),
            VoxelIndex(1, 0, 0),
            VoxelIndex(-1, 0, 0),
        ]

        let sumOpaqueNeighbors = try distance1neighbors.reduce(into: 0) { partialResult, locationOffset in
            let indexInCollection = VoxelIndex(x: vindex.x + locationOffset.x, y: vindex.y + locationOffset.y, z: vindex.z + locationOffset.z)
            if let voxel = try self.value(indexInCollection), voxel.isOpaque() {
                partialResult += 1
            }
        }
        return sumOpaqueNeighbors != 6
    }

    func isSurfaceFace(_ vindex: VoxelIndex, direction: CubeFace) throws -> Bool {
        let secondIndex = vindex.adding(direction.voxelIndexOffset)
        if let firstVoxel = try value(vindex) {
            // first voxel returned a value
            if let secondVoxel = try value(secondIndex) {
                return firstVoxel.isOpaque() != secondVoxel.isOpaque()
            } else {
                // second voxel didn't return a value, treat as though its not opaque
                return firstVoxel.isOpaque()
            }
        } else {
            // first voxel didn't return a value
            if let secondVoxel = try value(secondIndex), secondVoxel.isOpaque() {
                return true
            } else {
                return false
            }
        }
    }
}

public protocol VoxelRenderable {
    func isOpaque() -> Bool
    // consider adding a color type here?
}

public protocol StrideIndexable {
    func linearize(_ arr: VoxelIndex) throws -> Int
    func delinearize(_ arr: Int) throws -> VoxelIndex
}
