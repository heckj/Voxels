public struct VoxelHash<T>: VoxelAccessible {
    var _contents: [SIMD3<Int>: T]

    public init() {
        _contents = [:]
    }

    public var count: Int {
        _contents.count
    }

    // TODO: move this to VoxelAccessible... or a broader voxel collection thing...
    public var bounds: (min: SIMD3<Int>, max: SIMD3<Int>)? {
        if _contents.isEmpty {
            return nil
        } else {
            let keys = Array(_contents.keys)
            if keys.count == 1, let onlyKey = keys.first {
                return (min: onlyKey, max: onlyKey)
            } else {
                let firstKey = keys[0]
                var minX = firstKey.x
                var maxX = firstKey.x
                var minY = firstKey.y
                var maxY = firstKey.y
                var minZ = firstKey.z
                var maxZ = firstKey.z
                for thisKey in keys[1...] {
                    minX = Swift.min(minX, thisKey.x)
                    maxX = Swift.max(maxX, thisKey.x)
                    minY = Swift.min(minY, thisKey.y)
                    maxY = Swift.max(maxY, thisKey.y)
                    minZ = Swift.min(minZ, thisKey.z)
                    maxZ = Swift.max(maxZ, thisKey.z)
                }
                return (min: SIMD3<Int>(minX, minY, minZ), max: SIMD3<Int>(maxX, maxY, maxZ))
            }
        }
    }

    public func value(x: Int, y: Int, z: Int) -> T? {
        _contents[SIMD3<Int>(x, y, z)]
    }

    public subscript(position: SIMD3<Int>) -> T? {
        get {
            _contents[position]
        }
        set(newValue) {
            if let newValue {
                _contents[position] = newValue
            } else {
                _contents.removeValue(forKey: position)
            }
        }
    }
}

extension VoxelHash: Sequence {
    public func makeIterator() -> VoxelHashIterator {
        VoxelHashIterator(self)
    }

    public struct VoxelHashIterator: IteratorProtocol {
        var keys: [SIMD3<Int>]
        let originalVoxelHash: VoxelHash<T>

        init(_ originalVoxelHash: VoxelHash<T>) {
            keys = Array(originalVoxelHash._contents.keys)
            self.originalVoxelHash = originalVoxelHash
        }

        public mutating func next() -> T? {
            guard let key = keys.popLast() else {
                return nil
            }
            return originalVoxelHash[key]
        }
    }
}
