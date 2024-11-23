/// A collection of voxels backed by a hash table.
///
/// Useful for sparse voxel collections.
public struct VoxelHash<T: Sendable>: VoxelWritable {
    var _contents: [VoxelIndex: T]
    public var bounds: VoxelBounds
    let defaultVoxel: T?

    public init() {
        _contents = [:]
        bounds = .empty
        defaultVoxel = nil
    }

    public init(bounds: VoxelBounds) {
        _contents = [:]
        self.bounds = bounds
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
        if bounds == .empty, _contents.count == 1 {
            bounds = .init(vi)
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

extension VoxelHash: Sendable {}

extension VoxelHash: Equatable where T: Equatable {}
extension VoxelHash: Hashable where T: Hashable {}
