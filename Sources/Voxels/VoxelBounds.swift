public struct VoxelBounds {
    public let min: VoxelIndex
    public let max: VoxelIndex

    public init(_ only: VoxelIndex) {
        self.min = only
        self.max = only
    }

    public init(min: VoxelIndex, max: VoxelIndex) {
        self.min = min
        self.max = max
    }

    public init?(_ seqOfIndex: [VoxelIndex]) {
        if seqOfIndex.isEmpty {
            return nil
        }
        if seqOfIndex.count == 1 {
            self.init(seqOfIndex[0])
        } else {
            let firstKey = seqOfIndex[0]
            var minX = firstKey.x
            var maxX = firstKey.x
            var minY = firstKey.y
            var maxY = firstKey.y
            var minZ = firstKey.z
            var maxZ = firstKey.z
            for thisKey in seqOfIndex[1...] {
                minX = Swift.min(minX, thisKey.x)
                maxX = Swift.max(maxX, thisKey.x)
                minY = Swift.min(minY, thisKey.y)
                maxY = Swift.max(maxY, thisKey.y)
                minZ = Swift.min(minZ, thisKey.z)
                maxZ = Swift.max(maxZ, thisKey.z)
            }
            self.init(min: VoxelIndex(minX, minY, minZ), max: VoxelIndex(maxX, maxY, maxZ))
        }
    }

    @inlinable
    public func contains(_ point: VoxelIndex) -> Bool {
        (point.x >= min.x && point.x <= max.x) &&
            (point.y >= min.y && point.y <= max.y) &&
            (point.z >= min.z && point.z <= max.z)
    }

    @inlinable
    public func adding(_ newPoint: VoxelIndex) -> VoxelBounds {
        if contains(newPoint) {
            return self
        }
        if newPoint.x < min.x || newPoint.y < min.y || newPoint.z < min.z {
            return VoxelBounds(min: newPoint, max: max)
        } else {
            return VoxelBounds(min: min, max: newPoint)
        }
    }
}

extension VoxelBounds: Equatable {}
