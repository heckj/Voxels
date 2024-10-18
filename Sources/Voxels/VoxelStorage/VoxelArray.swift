import IssueReporting

/// A collection of voxels backed by an array.
public struct VoxelArray<T: Sendable>: VoxelWritable {
    var _contents: [T]
    public let bounds: VoxelBounds

    public var indices: [VoxelIndex] {
        bounds.indices
    }

    public init(edge: Int, value: T) {
        precondition(edge > 0)
        _contents = Array(repeating: value, count: edge * edge * edge)
        bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(edge - 1, edge - 1, edge - 1))
    }

    public init(bounds: VoxelBounds, initialValue: T) {
        self.bounds = bounds
        _contents = Array(repeating: initialValue, count: bounds.size)
    }

    public func value(_ vi: VoxelIndex) -> T? {
        let stride = bounds._unchecked_linearize(vi)
        return _contents[stride]
    }

    public mutating func set(_ vi: VoxelIndex, newValue: T) {
        let stride = bounds._unchecked_linearize(vi)
        _contents[stride] = newValue
    }

    public subscript(_ index: VoxelIndex) -> T? {
        get {
            let linearPosition = bounds._unchecked_linearize(index)
            if linearPosition < 0 || linearPosition > (_contents.count - 1) {
                return nil
            } else {
                return _contents[linearPosition]
            }
        }
        set(newValue) {
            guard let value = newValue else {
                return
            }
            let linearPosition = bounds._unchecked_linearize(index)
            precondition(linearPosition >= 0 && linearPosition < _contents.count)
            if linearPosition < 0 || linearPosition > _contents.count {
                return
            }
            _contents[linearPosition] = value
        }
    }
}

extension VoxelArray: Sendable {}
