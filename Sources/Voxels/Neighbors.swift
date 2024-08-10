struct Neighbors<T>: VoxelAccessible {
    // https://en.wikipedia.org/wiki/Von_Neumann_neighborhood
    let distance: Int
    var _storage: VoxelHash<T>

    static func manhattan_distance(from: SIMD3<Int>, to: SIMD3<Int>) -> Int {
        abs(from.x - to.x) + abs(from.y - to.y) + abs(from.z - to.z)
    }

    init(distance: Int, origin: SIMD3<Int>, voxels: some VoxelAccessible<T>) {
        precondition(distance > 0)
        self.distance = distance
        var initStorage = VoxelHash<T>()
        for i in origin.x - distance ... origin.x + distance {
            for j in origin.y - distance ... origin.y + distance {
                for k in origin.z - distance ... origin.z + distance {
                    let relativeLocation = SIMD3<Int>(i, j, k)
                    if Neighbors.manhattan_distance(from: origin, to: relativeLocation) <= distance {
                        if let voxelData = voxels[origin &+ relativeLocation] {
                            initStorage[relativeLocation] = voxelData
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
