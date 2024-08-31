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
        if newPoint < min {
            let minX = Swift.min(min.x, newPoint.x)
            let minY = Swift.min(min.y, newPoint.y)
            let minZ = Swift.min(min.z, newPoint.z)
            return VoxelBounds(min: VoxelIndex(minX, minY, minZ), max: max)
        } else if newPoint > max {
            let maxX = Swift.max(max.x, newPoint.x)
            let maxY = Swift.max(max.y, newPoint.y)
            let maxZ = Swift.max(max.z, newPoint.z)
            return VoxelBounds(min: min, max: VoxelIndex(maxX, maxY, maxZ))
        } else {
            return self
        }
    }
}

extension VoxelBounds: Equatable {}

extension VoxelBounds: StrideIndexable {
    @inline(__always)
    public var size: Int {
        let xDistance = self.max.x - self.min.x
        let yDistance = self.max.y - self.min.y
        let zDistance = self.max.z - self.min.z

        switch (xDistance > 0, yDistance > 0, zDistance > 0) {
        // MARK: 3D

        case (true, true, true):
            return (xDistance + 1) * (yDistance + 1) * (zDistance + 1)

        // MARK: 2D
        case (true, true, false): // x - y
            return (xDistance + 1) * (yDistance + 1)
        case (true, false, true): // x - z
            return (xDistance + 1) * (zDistance + 1)
        case (false, true, true): // y - z
            return (yDistance + 1) * (zDistance + 1)

        // MARK: 1D
        case (true, false, false): // x
            return xDistance + 1
        case (false, true, false): // y
            return yDistance + 1
        case (false, false, true): // z
            return zDistance + 1

        // MARK: 0D
        case (false, false, false):
            return 0
        }
    }

    @inline(__always)
    public func linearize(_ vi: VoxelIndex) throws -> Int {
        if !contains(vi) {
            throw VoxelAccessError.outOfBounds("Index out of bounds: \(vi)")
        }
        return _unchecked_linearize(vi)
    }

    @inline(__always)
    public func delinearize(_ strideIndex: Int) throws -> VoxelIndex {
        if strideIndex < 0 || strideIndex >= size {
            throw VoxelAccessError.outOfBounds("stride index out of bounds: \(strideIndex)")
        }
        return _unchecked_delinearize(strideIndex)
    }

    @inline(__always)
    func _unchecked_delinearize(_ strideIndex: Int) -> VoxelIndex {
        let xDistance = self.max.x - self.min.x // 2
        let yDistance = self.max.y - self.min.y // 2
        let zDistance = self.max.z - self.min.z // 0

        // 2

        switch (xDistance > 0, yDistance > 0, zDistance > 0) {
        // MARK: 3D

        case (true, true, true):
            let majorStride = (xDistance + 1) * (yDistance + 1)
            let minorStride = (yDistance + 1)
            var x = 0
            if strideIndex >= majorStride {
                x = strideIndex / majorStride
            }

            let remaining = strideIndex - (x * majorStride)
            var y = 0
            if remaining >= minorStride {
                y = remaining / minorStride
            }

            let z = remaining - (y * minorStride)
            return min.adding(VoxelIndex(x, y, z))

        // MARK: 2D
        case (true, true, false): // x, y

            // xDistance = 2
            // stride 0 -> [0,0,0]
            // stride 1 -> [0,1,0]
            // stride 2 -> [0,2,0]
            // stride 3 -> [1,0,0]
            // stride 4 -> [1,1,0]
            var x = 0
            if strideIndex > xDistance {
                x = strideIndex / (xDistance + 1)
            }
            let remaining = strideIndex - (x * (xDistance + 1))
            return min.adding(VoxelIndex(x, remaining, 0))
        case (true, false, true): // x, z
            var x = 0
            if strideIndex > xDistance {
                x = strideIndex / (xDistance + 1)
            }
            let remaining = strideIndex - (x * (xDistance + 1))
            return min.adding(VoxelIndex(x, 0, remaining))
        case (false, true, true): // y, z
            var y = 0
            if strideIndex > yDistance {
                y = strideIndex / (yDistance + 1)
            }
            let remaining = strideIndex - (y * (yDistance + 1))
            return min.adding(VoxelIndex(0, y, remaining))

        // MARK: 1D
        case (true, false, false): // x
            return min.adding(VoxelIndex(strideIndex, 0, 0))
        case (false, true, false): // y
            return min.adding(VoxelIndex(0, strideIndex, 0))
        case (false, false, true): // z
            return min.adding(VoxelIndex(0, 0, strideIndex))

        // MARK: 0D
        case (false, false, false):
            return min
        }
    }

    @inline(__always)
    func _unchecked_linearize(_ vi: VoxelIndex) -> Int {
        let xDistance = self.max.x - self.min.x
        let yDistance = self.max.y - self.min.y
        let zDistance = self.max.z - self.min.z

        switch (xDistance > 0, yDistance > 0, zDistance > 0) {
        // MARK: 3D

        case (true, true, true):
            // print("3d")
            let majorStride = (xDistance + 1) * (yDistance + 1)
            let minorStride = yDistance + 1
            let majorOffset = (vi.x - min.x) * majorStride
            let minorOffset = (vi.y - min.y) * minorStride
            let finalOffset = (vi.z - min.z)
            return majorOffset + minorOffset + finalOffset

        // MARK: 2D
        case (true, true, false): // x, y
            let minorStride = xDistance + 1
            let minorOffset = (vi.x - min.x) * minorStride
            let finalOffset = (vi.y - min.y)
            return minorOffset + finalOffset
        case (true, false, true): // x, z
            let minorStride = xDistance + 1
            let minorOffset = (vi.x - min.x) * minorStride
            let finalOffset = (vi.z - min.z)
            return minorOffset + finalOffset
        case (false, true, true): // y, z
            let minorStride = yDistance + 1
            let minorOffset = (vi.y - min.y) * minorStride
            let finalOffset = (vi.z - min.z)
            return minorOffset + finalOffset

        // MARK: 1D
        case (true, false, false): // x
            return vi.x - min.x
        case (false, true, false): // y
            return vi.y - min.y
        case (false, false, true): // z
            return vi.z - min.z

        // MARK: 0D
        case (false, false, false):
            return 0
        }
        // Row-major address by index:
        //
        //    Address of A[i][j][k] = B + W *(P* N * (i-x) + P*(j-y) + (k-z))
        //
        //    Here:
        //
        //    B = Base Address (start address)                             = 0
        //    W = Weight (storage size of one element stored in the array) = 1
        //    M = Row (total number of rows)                               = size
        //    N = Column (total number of columns)                         = size
        //    P = Width (total number of cells depth-wise)                 = size
        //    x = Lower Bound of Row                                       = 0
        //    y = Lower Bound of Column                                    = 0
        //    z = Lower Bound of Width                                     = 0
    }

    var indices: [VoxelIndex] {
        (0 ..< size).map { _unchecked_delinearize($0) }
    }
}
