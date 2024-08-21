public struct VoxelHash<T: VoxelRenderable, R: SIMDScalar>: VoxelWritable {
    var _contents: [VoxelIndex: T]
    public var bounds: VoxelBounds?
    public let scale: VoxelScale<R>

    public init() where R: FixedWidthInteger {
        _contents = [:]
        bounds = nil
        scale = VoxelScale<R>(origin: SIMD3<R>(x: 0, y: 0, z: 0), cubeSize: R(1))
    }

    public init() where R: BinaryFloatingPoint {
        _contents = [:]
        bounds = nil
        scale = VoxelScale<R>(origin: SIMD3<R>(x: 0, y: 0, z: 0), cubeSize: R(1.0))
    }

    public init(origin: SIMD3<R>, edgeLength: R) {
        _contents = [:]
        bounds = nil
        scale = VoxelScale<R>(origin: origin, cubeSize: edgeLength)
    }

    public var count: Int {
        _contents.count
    }

    public func value(_ vi: VoxelIndex) -> T? {
        _contents[vi]
    }

    public mutating func set(_ vi: VoxelIndex, newValue: T) throws {
        _contents[vi] = newValue
        updateBoundsAdding(vi)
    }

    private mutating func updateBoundsAdding(_ vi: VoxelIndex) {
        if let bounds {
            self.bounds = bounds.adding(vi)
        } else {
            bounds = VoxelBounds(vi)
        }
    }

    public mutating func set(_ vi: VoxelIndex, newValue: T?) throws {
        if let aValue = newValue {
            _contents[vi] = aValue
            updateBoundsAdding(vi)
        } else {
            _contents.removeValue(forKey: vi)
            updateBoundsRemoving(vi)
        }
    }

    private mutating func updateBoundsRemoving(_ vi: VoxelIndex) {
        if let bounds, vi == bounds.min || vi == bounds.max {
            self.bounds = VoxelBounds(Array(_contents.keys))
        }
    }
}

extension VoxelHash: Sequence {
    public func makeIterator() -> VoxelHashIterator {
        VoxelHashIterator(self)
    }

    public struct VoxelHashIterator: IteratorProtocol {
        var keys: [VoxelIndex]
        let originalVoxelHash: VoxelHash<T, R>

        init(_ originalVoxelHash: VoxelHash<T, R>) {
            keys = Array(originalVoxelHash._contents.keys)
            self.originalVoxelHash = originalVoxelHash
        }

        public mutating func next() -> T? {
            guard let key = keys.popLast() else {
                return nil
            }
            return originalVoxelHash.value(key)
        }
    }
}
