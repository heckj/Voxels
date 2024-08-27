public struct Neighbors<T: VoxelRenderable>: VoxelAccessible {
    // https://en.wikipedia.org/wiki/Von_Neumann_neighborhood
    let distance: Int
    var _storage: VoxelHash<T>
    public var bounds: VoxelBounds {
        _storage.bounds
    }

    public var indices: any Sequence<VoxelIndex> {
        _storage.indices
    }

    static func manhattan_distance(from: VoxelIndex, to: VoxelIndex) -> Int {
        abs(from.x - to.x) + abs(from.y - to.y) + abs(from.z - to.z)
    }

    public enum NeighborStrategy {
        case raw
        case opaque
        case surface
    }

    public init(distance: Int, origin: VoxelIndex, voxels: any VoxelAccessible<T>, strategy: NeighborStrategy = .raw) throws {
        precondition(distance >= 0)
        self.distance = distance
        var initStorage = VoxelHash<T>()
        for i in origin.x - distance ... origin.x + distance {
            for j in origin.y - distance ... origin.y + distance {
                for k in origin.z - distance ... origin.z + distance {
                    let computedIndex = VoxelIndex(i, j, k)
                    if Neighbors.manhattan_distance(from: origin, to: computedIndex) <= distance {
                        if let voxelData = try voxels.value(computedIndex) {
                            switch strategy {
                            case .raw:
                                initStorage.set(computedIndex, newValue: voxelData)
                            case .opaque:
                                if voxelData.isOpaque() {
                                    initStorage.set(computedIndex, newValue: voxelData)
                                }
                            case .surface:
                                do {
                                    if try voxels.isSurface(computedIndex) {
                                        initStorage.set(computedIndex, newValue: voxelData)
                                    }
                                } catch {}
                            }
                        }
                    }
                }
            }
        }
        _storage = initStorage
    }

    // VoxelAccessible

    public func value(_ index: VoxelIndex) -> T? {
        _storage.value(index)
    }

    public mutating func set(_ index: VoxelIndex, newValue: T) {
        _storage.set(index, newValue: newValue)
    }
}

extension Neighbors: Sequence {
    public func makeIterator() -> VoxelHash<T>.VoxelHashIterator {
        _storage.makeIterator()
    }
}
