public struct VoxelHash<T>: VoxelAccessible {
    var _contents: [SIMD3<Int>: T]

    public init() {
        _contents = [:]
    }

    public var count: Int {
        _contents.count
    }

    public var size: (min: SIMD3<Int>, max: SIMD3<Int>) {
        if _contents.isEmpty {
            return (min: .zero, max: .zero)
        } else {
            let minSIMD: SIMD3<Int> = _contents.keys.reduce(into: SIMD3<Int>.zero) { partialResult, nextTestValue in
                let minX = min(partialResult.x, nextTestValue.x)
                let minY = min(partialResult.y, nextTestValue.y)
                let minZ = min(partialResult.z, nextTestValue.z)
                partialResult = SIMD3<Int>(minX, minY, minZ)
            }

            let maxSIMD: SIMD3<Int> = _contents.keys.reduce(into: SIMD3<Int>.zero) { partialResult, nextTestValue in
                let maxX = max(partialResult.x, nextTestValue.x)
                let maxY = max(partialResult.y, nextTestValue.y)
                let maxZ = max(partialResult.z, nextTestValue.z)
                partialResult = SIMD3<Int>(maxX, maxY, maxZ)
            }
            return (min: minSIMD, max: maxSIMD)
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
