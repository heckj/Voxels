struct Neighbors<T: VoxelRenderable>: VoxelAccessible {
    // https://en.wikipedia.org/wiki/Von_Neumann_neighborhood
    let distance: Int
    var _storage: VoxelHash<T>

    static func manhattan_distance(from: SIMD3<Int>, to: SIMD3<Int>) -> Int {
        abs(from.x - to.x) + abs(from.y - to.y) + abs(from.z - to.z)
    }

    public enum NeighborStrategy {
        case raw
        case opaque
        case surface
    }

    init(distance: Int, origin: SIMD3<Int>, voxels: some VoxelAccessible<T>, strategy: NeighborStrategy = .raw) {
        precondition(distance >= 0)
        self.distance = distance
        var initStorage = VoxelHash<T>()
        for i in origin.x - distance ... origin.x + distance {
            for j in origin.y - distance ... origin.y + distance {
                for k in origin.z - distance ... origin.z + distance {
                    let relativeLocation = SIMD3<Int>(i, j, k)
                    if Neighbors.manhattan_distance(from: origin, to: relativeLocation) <= distance {
                        let simdIndex = origin &+ relativeLocation
                        if let voxelData = voxels[simdIndex] {
                            switch strategy {
                            case .raw:
                                initStorage[simdIndex] = voxelData
                            case .opaque:
                                if voxelData.isOpaque() {
                                    initStorage[simdIndex] = voxelData
                                }
                            case .surface:
                                do {
                                    if try voxels.isSurface(x: simdIndex.x, y: simdIndex.y, z: simdIndex.z) {
                                        initStorage[simdIndex] = voxelData
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

    func value(x: Int, y: Int, z: Int) -> T? {
        _storage[SIMD3<Int>(x, y, z)]
    }

    subscript(position: SIMD3<Int>) -> T? {
        _storage[position]
    }
}
