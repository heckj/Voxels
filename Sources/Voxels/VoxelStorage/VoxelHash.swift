public struct VoxelHash<T: VoxelRenderable>: VoxelWritable {
    var _contents: [VoxelIndex: T]
    public var bounds: VoxelBounds
    let defaultVoxel: T?

    public var indices: any Sequence<VoxelIndex> {
        _contents.keys
    }

    public init() {
        _contents = [:]
        bounds = .empty
        defaultVoxel = nil
    }

    public init(defaultVoxel: T) {
        _contents = [:]
        bounds = .empty
        self.defaultVoxel = defaultVoxel
    }

    public var count: Int {
        _contents.count
    }

    public func value(_ vi: VoxelIndex) -> T? {
        if let aVoxel = _contents[vi] {
            aVoxel
        } else {
            defaultVoxel
        }
    }

    public mutating func set(_ vi: VoxelIndex, newValue: T) throws {
        _contents[vi] = newValue
        updateBoundsAdding(vi)
    }

    private mutating func updateBoundsAdding(_ vi: VoxelIndex) {
        bounds = bounds.adding(vi)
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

    public mutating func set(_ vis: [VoxelIndex], newValue: T?) throws {
        if let aValue = newValue {
            for index in vis {
                _contents[index] = aValue
                updateBoundsAdding(index)
            }
        } else {
            for index in vis {
                _contents.removeValue(forKey: index)
                updateBoundsRemoving(index)
            }
        }
    }

    private mutating func updateBoundsRemoving(_ vi: VoxelIndex) {
        if vi == bounds.min || vi == bounds.max {
            bounds = VoxelBounds(Array(_contents.keys))
        }
    }
}

extension VoxelHash: Sequence {
    public func makeIterator() -> VoxelHashIterator {
        VoxelHashIterator(self)
    }

    public struct VoxelHashIterator: IteratorProtocol {
        var keys: [VoxelIndex]
        let originalVoxelHash: VoxelHash<T>

        init(_ originalVoxelHash: VoxelHash<T>) {
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
