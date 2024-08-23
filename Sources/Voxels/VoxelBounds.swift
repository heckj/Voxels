public struct VoxelBounds: Sendable {
    public let min: VoxelIndex
    public let max: VoxelIndex

    public static let empty: VoxelBounds = .init(VoxelIndex())

    public init(_ only: VoxelIndex) {
        self.min = only
        self.max = only
    }

    public init(min: VoxelIndex, max: VoxelIndex) {
        self.min = min
        self.max = max
    }

    public init(_ seqOfIndex: [VoxelIndex]) {
        if seqOfIndex.isEmpty {
            self.init(VoxelIndex())
        } else if seqOfIndex.count == 1 {
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

extension VoxelBounds: Sequence {
    public func makeIterator() -> VoxelBoundsIterator {
        VoxelBoundsIterator(self)
    }

    public struct VoxelBoundsIterator: IteratorProtocol {
        let bounds: VoxelBounds
        var x, y, z: Int

        init(_ bounds: VoxelBounds) {
            self.bounds = bounds
            x = bounds.min.x
            y = bounds.min.y
            z = bounds.min.z
        }

        public mutating func next() -> VoxelIndex? {
            // crazily converting a multiple wrapped for loop
            // into an iterator pattern...
            if x < bounds.max.x {
                x += 1
                return VoxelIndex(x: x, y: y, z: z)
            } else {
                x = bounds.min.x
                if y < bounds.max.y {
                    y += 1
                    return VoxelIndex(x: x, y: y, z: z)
                } else {
                    y = bounds.min.y
                    if z < bounds.max.z {
                        z += 1
                        return VoxelIndex(x: x, y: y, z: z)
                    } else {
                        return nil
                    }
                }
            }
        }
    }
}
