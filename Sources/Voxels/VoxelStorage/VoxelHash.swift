/// A collection of voxels backed by a hash table.
///
/// Useful for sparse voxel collections.
public struct VoxelHash<T: Sendable>: VoxelWritable, Sendable {
    var _contents: [VoxelIndex: T]
    public var bounds: VoxelBounds
    let defaultVoxel: T?

    public var indices: [VoxelIndex] {
        bounds.indices
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

    public init(_ otherVoxels: VoxelHash<T>, defaultVoxel: T) {
        _contents = otherVoxels._contents
        bounds = otherVoxels.bounds
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

    public mutating func set(_ vi: VoxelIndex, newValue: T) {
        _contents[vi] = newValue
        updateBoundsAdding(vi)
    }

    private mutating func updateBoundsAdding(_ vi: VoxelIndex) {
        if _contents.count == 1 {
            bounds = VoxelBounds(vi)
        } else {
            bounds = bounds.adding(vi)
        }
    }

    public mutating func set(_ vi: VoxelIndex, newValue: T?) {
        if let aValue = newValue {
            _contents[vi] = aValue
            updateBoundsAdding(vi)
        } else {
            _contents.removeValue(forKey: vi)
            updateBoundsRemoving(vi)
        }
    }

    public mutating func set(_ vis: [VoxelIndex], newValue: T?) {
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

    public subscript(_ index: VoxelIndex) -> T? {
        get {
            value(index)
        }
        set(newValue) {
            set(index, newValue: newValue)
        }
    }
}

extension VoxelHash: Sequence {
    public typealias Iterator = VoxelHashIndexIterator
    public func makeIterator() -> VoxelHashIndexIterator {
        VoxelHashIndexIterator(self)
    }

    public struct VoxelHashIndexIterator: IteratorProtocol {
        var indexPosition: Dictionary<VoxelIndex, T>.Index
        let originalVoxelHash: VoxelHash<T>

        init(_ originalVoxelHash: VoxelHash<T>) {
            self.originalVoxelHash = originalVoxelHash
            indexPosition = self.originalVoxelHash._contents.startIndex
        }

        public mutating func next() -> T? {
            if indexPosition < originalVoxelHash._contents.endIndex {
                let foo: (key: VoxelIndex, value: T) = originalVoxelHash._contents[indexPosition]
                indexPosition = originalVoxelHash._contents.index(after: indexPosition)
                return foo.value
            } else {
                return nil
            }
        }
    }
}

extension VoxelHash: Collection {
    public typealias Index = Dictionary<VoxelIndex, T>.Index

    public var startIndex: Dictionary<VoxelIndex, T>.Index {
        _contents.startIndex
    }

    public var endIndex: Dictionary<VoxelIndex, T>.Index {
        _contents.endIndex
    }

    public func index(after: Dictionary<VoxelIndex, T>.Index) -> Dictionary<VoxelIndex, T>.Index {
        _contents.index(after: after)
    }

    public subscript(position: Dictionary<VoxelIndex, T>.Index) -> T {
        let foo: (key: VoxelIndex, value: T) = _contents[position]
        return foo.value
    }
}
