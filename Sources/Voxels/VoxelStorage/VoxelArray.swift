/// A collection of voxels backed by an array.
public struct VoxelArray<T: Sendable>: VoxelWritable {
    var _contents: [T]
    public let edgeSize: Int
    public var bounds: VoxelBounds

    public var indices: [VoxelIndex] {
        (0 ..< bounds.size).map { bounds._unchecked_delinearize($0) }
    }

    public init(edge: Int, value: T) {
        precondition(edge > 0)
        edgeSize = edge
        _contents = Array(repeating: value, count: edge * edge * edge)
        bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(edge - 1, edge - 1, edge - 1))
    }

    public func value(_ vi: VoxelIndex) throws -> T? {
        let stride = try bounds.linearize(vi)
        return _contents[stride]
    }

    public mutating func set(_ vi: VoxelIndex, newValue: T) throws {
        let stride = try bounds.linearize(vi)
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
            if linearPosition >= 0 || linearPosition < _contents.count {
                return
            }
            precondition(linearPosition >= 0 && linearPosition < _contents.count)
            _contents[linearPosition] = value
        }
    }
}

extension VoxelArray: Sendable {}
