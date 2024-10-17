public extension VoxelBounds {
    /// Returns the intersection of the bounds sliced along the X axis.
    /// - Parameter range: the slice of vertex indices along the X axis.
    func x(_ range: ClosedRange<Int>) -> VoxelBounds {
        switch (range.lowerBound >= min.x, range.upperBound <= max.x) {
        case (true, true):
            VoxelBounds(min: .init(x: range.lowerBound, y: min.y, z: min.z),
                        max: .init(x: range.upperBound, y: max.y, z: max.z))
        case (true, false):
            VoxelBounds(min: .init(x: range.lowerBound, y: min.y, z: min.z),
                        max: .init(x: max.x, y: max.y, z: max.z))
        case (false, true):
            VoxelBounds(min: .init(x: min.x, y: min.y, z: min.z),
                        max: .init(x: range.upperBound, y: max.y, z: max.z))
        case (false, false):
            self
        }
    }

    /// Returns the intersection of the bounds sliced along the Y axis.
    /// - Parameter range: the slice of vertex indices along the Y axis.
    func y(_ range: ClosedRange<Int>) -> VoxelBounds {
        switch (range.lowerBound >= min.y, range.upperBound <= max.y) {
        case (true, true):
            VoxelBounds(min: .init(x: min.x, y: range.lowerBound, z: min.z),
                        max: .init(x: max.x, y: range.upperBound, z: max.z))
        case (true, false):
            VoxelBounds(min: .init(x: min.x, y: range.lowerBound, z: min.z),
                        max: .init(x: max.x, y: max.y, z: max.z))
        case (false, true):
            VoxelBounds(min: .init(x: min.x, y: min.y, z: min.z),
                        max: .init(x: max.x, y: range.upperBound, z: max.z))
        case (false, false):
            self
        }
    }

    /// Returns the intersection of the bounds sliced along the Z axis.
    /// - Parameter range: the slice of vertex indices along the Z axis.
    func z(_ range: ClosedRange<Int>) -> VoxelBounds {
        switch (range.lowerBound >= min.z, range.upperBound <= max.z) {
        case (true, true):
            VoxelBounds(min: .init(x: min.x, y: min.y, z: range.lowerBound),
                        max: .init(x: max.x, y: max.y, z: range.upperBound))
        case (true, false):
            VoxelBounds(min: .init(x: min.x, y: min.y, z: range.lowerBound),
                        max: .init(x: max.x, y: max.y, z: max.z))
        case (false, true):
            VoxelBounds(min: .init(x: min.x, y: min.y, z: min.z),
                        max: .init(x: max.x, y: max.y, z: range.upperBound))
        case (false, false):
            self
        }
    }
}
