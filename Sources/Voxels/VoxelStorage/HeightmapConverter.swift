import Heightmap

public enum HeightmapConverter {
    /// Returns the unit height value for the center of the voxel at the index you provide.
    ///
    /// For example, for a set of voxels with a maximum voxel index of `4`:
    ///
    /// ```
    ///    +---
    ///  4 | .  --> 1.00
    ///    +---
    ///  3 | .  --> 0.75
    ///    +---
    ///  2 | .  --> 0.50
    ///    +---
    ///  1 | .  --> 0.25
    ///    +---
    ///  0 | .  --> 0.00
    ///    +---
    /// ```
    ///
    /// - Parameters:
    ///   - heightIndex: The voxel index value of the height of the voxel.
    ///   - maxHeight: The maximum number of vertical voxels.
    @inlinable
    static func unitCentroidValue(_ heightIndex: Int, maxVoxelIndex: Int) -> Float {
        Float(heightIndex) / Float(maxVoxelIndex)
    }

    /// Returns a 3-dimensional position that represents the center of the voxel from the voxel index and its size.
    ///
    /// ```
    ///          size: 1  size: 0.5
    ///    +---
    ///  4 | .  --> 4      2
    ///    +---
    ///  3 | .  --> 3      1.5
    ///    +---
    ///  2 | .  --> 2      1
    ///    +---
    ///  1 | .  --> 1      0.5
    ///    +---
    ///  0 | .  --> 0      0
    ///    +---
    /// ```
    @inlinable
    static func sizedPositionOfCenter(xz: XZIndex, y: Int, voxelSize: Float) -> SIMD3<Float> {
        SIMD3<Float>(Float(xz.x) * voxelSize, Float(y) * voxelSize, Float(xz.z) * voxelSize)
    }

    /// Returns a 3-dimensional position that represents the coordinate location of the surface given
    /// a unit-height, the index locations for X and Z, and the sizes of the voxel array and voxels.
    ///
    /// ```
    /// unit height
    /// of 0.33           -> 1.32     -> 0.66
    ///
    ///             unit    size: 1  size: 0.5
    ///    +---
    ///  4 | .  --> 1.00      4        2.0
    ///    +---
    ///  3 | .  --> 0.75      3        1.5
    ///    +---
    ///  2 | .  --> 0.50      2        1.0
    ///    +---
    ///  1 | .  --> 0.25      1        0.5
    ///    +---
    ///  0 | .  --> 0.00      0        0.0
    ///    +---
    /// ```
    @inlinable
    static func sizedSurfaceLocation(xz: XZIndex, unitHeight: Float, maxVoxelIndex: Int, voxelSize: Float) -> SIMD3<Float> {
        let yCoordinate = unitHeight * Float(maxVoxelIndex) * voxelSize
        return SIMD3<Float>(Float(xz.x) * voxelSize,
                            yCoordinate,
                            Float(xz.z) * voxelSize)
    }

    /// Returns the vertically-computed SDF value for the Y voxel index for the unit height value you provide.
    /// - Parameters:
    ///   - unitValue: The unit value height.
    ///   - y: The y index of the voxel.
    ///   - maxVoxelHeight: The maximum number of voxels.
    ///   - voxelSize: The height of a single voxel.
    ///
    /// The function only computes the distance to the surface vertically, and does not
    /// consider or estimate any surrounding voxels.
    /// For example, for a set of voxels with a maximum voxel index of `4`, a unit-height value of `0.25`,
    /// and a voxel size of `1.0`:
    ///
    /// For example, for a set of voxels with a maximum voxel index of `4`,
    /// a unit-height value of `0.25`, and a voxel size of `1.0`:
    /// ```
    ///           unit-value   SDF     SDF
    ///           at center   value   value
    ///                      (0.25)  (0.33)
    ///    +---
    ///  4 | .  --> 1.00  ...  3.0   2.68
    ///    +---
    ///  3 | .  --> 0.75  ...  2.0   1.68
    ///    +---
    ///  2 | .  --> 0.50  ...  1.0   0.68
    ///    +---
    ///  1 | .  --> 0.25  ...  0.0  -0.32
    ///    +---
    ///  0 | .  --> 0.00  ... -1.0  -1.32
    ///    +---
    ///    ```

    @inlinable
    static func SDFValueAtHeight(_ unitValue: Float, at y: Int, maxVoxelIndex: Int, voxelSize: Float) -> Float {
        // get unit centroid value of this index
        let centroidFloatOfYIndex = unitCentroidValue(y, maxVoxelIndex: maxVoxelIndex)
        // compute the unit difference
        let difference = centroidFloatOfYIndex - unitValue
        // scale the difference by the size of each voxel to get the final SDF value
        return difference * Float(maxVoxelIndex) * voxelSize
    }

    /// Returns the unit height value given the Y index value and the SDF at that index, using the
    /// height and size of the voxels to scale the result.
    ///
    /// - Parameters:
    ///   - y: The Y index location
    ///   - sdf: The SDF value at that index
    ///   - maxVoxelIndex: The maximum voxel index
    ///   - voxelSize: The size of each voxel
    ///
    /// This effectively the inverse of ``SDFValueAtHeight``.
    ///
    /// For example, for a set of voxels with a maximum voxel index of `4`,
    /// a unit-height value of `0.25`, and a voxel size of `1.0`:
    /// ```
    ///           unit-value   SDF     SDF
    ///           at center   value   value
    ///                      (0.25)  (0.33)
    ///    +---
    ///  4 | .  --> 1.00  ...  3.0   2.68
    ///    +---
    ///  3 | .  --> 0.75  ...  2.0   1.68
    ///    +---
    ///  2 | .  --> 0.50  ...  1.0   0.68
    ///    +---
    ///  1 | .  --> 0.25  ...  0.0  -0.32
    ///    +---
    ///  0 | .  --> 0.00  ... -1.0  -1.32
    ///    +---
    ///    ```
    @inlinable
    static func unitHeightValueAtIndex(y: Int, sdf: Float, maxVoxelIndex: Int, voxelSize: Float) -> Float {
        let unitHeightAtCenterIndex = unitCentroidValue(y, maxVoxelIndex: maxVoxelIndex)
        // each index point shifts unit height this amount
        let indexIncrement = voxelSize / Float(maxVoxelIndex)

        // SDF is relative to voxelSize, so expand or contract based on that
        let SDFDistanceToUnitDistance = sdf / voxelSize
        // since negative values indicate "below surface", we substract the negative value
        // from the unitHeight to get the positive scaled increment in unit height to add
        // to the base index.
        let result = unitHeightAtCenterIndex - (SDFDistanceToUnitDistance * indexIncrement)
        return result
    }

    /// Returns the Y index value that maps to the surface value location from the height map.
    /// - Parameters:
    ///   - x: The x index of the voxel pillar
    ///   - z: The z index of the voxel pillar
    ///   - heightmap: The height
    ///   - maxHeight: The maximum number of vertical voxels.
    @inlinable
    static func indexOfSurface(_ p: XZIndex, heightmap: Heightmap, maxVoxelIndex: Int) -> Int {
        indexOfSurface(heightmap[p], maxVoxelIndex: maxVoxelIndex)
    }

    /// Returns the Y index value that maps to the surface value location from the height map.
    /// - Parameters:
    ///   - unitHeight: The unit-value of height
    ///   - maxHeight: The maximum number of vertical voxels.
    @inlinable
    static func indexOfSurface(_ unitHeight: Float, maxVoxelIndex: Int) -> Int {
        // convert 0...1 -> 0...(maxVoxelHeight - 1)
        let mappedUnitHeightValue = unitHeight * Float(maxVoxelIndex - 1)

        // loosely equiv to floor() - gets the lower index position for the voxel Index
        let yIndex = Int(mappedUnitHeightValue.rounded(.towardZero))

        return yIndex
    }

    /// Returns a collection of XZIndex locations around the point you provide that reside within the voxel bounds you specify.
    /// - Parameters:
    ///   - x: The x index location.
    ///   - z: The z index location.
    ///   - widthCount: The maximum number of voxels wide.
    ///   - depthCount: The maximum number of voxels deep.
    @inlinable
    static func twoDIndexNeighborsFrom(position: XZIndex, widthCount: Int, depthCount: Int) -> [XZIndex] {
        var neighbors: [XZIndex] = []
        for possibleX in position.x - 1 ... position.x + 1 {
            for possibleZ in position.z - 1 ... position.z + 1 {
                if possibleX >= 0, possibleX < widthCount, // bounding possible neighbors by width
                   possibleZ >= 0, possibleZ < depthCount, // bounding possible neighbors by depth
                   !(position.x == possibleX && position.z == possibleZ) // don't include the originating position in neighbor list
                {
                    neighbors.append(XZIndex(x: possibleX, z: possibleZ))
                }
            }
        }
        return neighbors
    }

    /// Computes the minimum distance between a point and a line in three dimensional space.
    /// - Parameters:
    ///   - p: The point to measure from.
    ///   - x1: A first point that defines the line.
    ///   - x2: The second point that defines the line.
    /// - Returns: The minimum distance between the point and the line.
    @inlinable
    static func distanceFromPointToLine(p: SIMD3<Float>, x1: SIMD3<Float>, x2: SIMD3<Float>) -> Float {
        // https://mathworld.wolfram.com/Point-LineDistance3-Dimensional.html
        //  | (p - x1) X (x0 - x2) |
        // --------------------------
        //       | (x2 - x1) |
        let top = (p - x1).cross(p - x2)
        let bottom = x2 - x1
        return top.length / bottom.length
    }

    /// Computes a height map from the collection of voxels with SDF data.
    ///
    /// If a coordinate location has no voxels, the height map value is returned as 0.
    /// - Returns: A height map of the highest surface represented in the voxels SDF values.
    public static func heightmap(from v: VoxelHash<Float>, voxelSize: Float) -> Heightmap {
        let width = (v.bounds.max.x - v.bounds.min.x) + 1
        let heightmapSize = width * (v.bounds.max.z - v.bounds.min.z + 1)

        var unitHeightMap: [Float] = []
        for linearIndexStep in 0 ..< heightmapSize {
            // convert this step in the iteration into an X and Z coordinate
            let xz = XZIndex.strideToXZ(linearIndexStep, width: width)
            // create list from the vertical column of voxels at this coordinate, iterating from
            // highest to lowest, and determine the first one of those voxels where the stored SDF
            // value goes negative.
            let yIndicesToCheckInOrder: [Int] = (v.bounds.min.y ... v.bounds.max.y).reversed()
            let highestNegativeSDFYIndex: Int? = yIndicesToCheckInOrder.first(where: { yToCheck in
                if let value = v[VoxelIndex(xz.x, yToCheck, xz.z)] {
                    return value <= 0
                }
                return false
            })
            if let highestNegativeSDFYIndex,
               let SDFValueAtIndex = v[VoxelIndex(xz.x, highestNegativeSDFYIndex, xz.z)]
            {
                // compute the unit height from the index and its SDF value
                // SDF value is -0.5 and index = 0, that means the unit height is above us by some amount
                let unitHeight = unitHeightValueAtIndex(y: highestNegativeSDFYIndex, sdf: SDFValueAtIndex, maxVoxelIndex: v.bounds.max.y, voxelSize: voxelSize)
                unitHeightMap.append(unitHeight)
            } else {
                unitHeightMap.append(0.0)
            }
        }
        return Heightmap(unitHeightMap, width: width)
    }

    @inlinable
    static func SDFDistanceClosestToSurface(initial: Float, values: [Float]) -> Float {
        var lowest = initial
        for value in values {
            if abs(value) < abs(lowest) {
                lowest = value
            }
        }
        return lowest
    }

    /// Creates a collection of Voxels from a height map
    /// - Parameters:
    ///   - heightmap: The Heightmap that represents the relative height at each x and z voxel index.
    ///   - maxVoxelHeight: The maximum height of voxels.
    public static func heightmap(_ heightmap: Heightmap,
                                 maxVoxelIndex: Int,
                                 voxelSize: Float, extendToFloor: Bool = false) -> VoxelHash<Float>
    {
        precondition(heightmap.width > 0)

        var voxels = VoxelHash<Float>(defaultVoxel: 1.0)
        for (stride, value) in heightmap.enumerated() {
            // get the X and Z coordinate index for this column of voxels from the height map
            let xzPosition = XZIndex.strideToXZ(stride, width: heightmap.width)

            if xzPosition == XZIndex(x: 3, z: 3) { // 3,3
                print(".")
            }
            // compute a list of the valid neighbor X and Z coordinates that are within the bounds
            // of the height map
            let surroundingNeighbors: [XZIndex] = twoDIndexNeighborsFrom(position: xzPosition, widthCount: heightmap.width, depthCount: heightmap.height)

            // get a list of the VoxelIndex positions of the surface for the neighbor voxel columns
            let neighborsSurfaceVoxelIndex: [VoxelIndex] = surroundingNeighbors.map { xz in
                let yIndexForNeighbor = indexOfSurface(xz, heightmap: heightmap, maxVoxelIndex: maxVoxelIndex)
                return VoxelIndex(xz.x, yIndexForNeighbor, xz.z)
            }

            let yIndex = indexOfSurface(value, maxVoxelIndex: maxVoxelIndex)

            let minYIndexOfNeighbors: Int = neighborsSurfaceVoxelIndex.reduce(yIndex) { partialResult, vIndex in
                Swift.min(partialResult, vIndex.y)
            }
            let maxYIndexOfNeighbors: Int = neighborsSurfaceVoxelIndex.reduce(yIndex) { partialResult, vIndex in
                Swift.max(partialResult, vIndex.y)
            }

            // Compute the range of voxels to be "filled in" with data from the height map.

            // The minimum value is either the floor (0) or one beneath the lowest Yindex from this column
            // and its neighbors
            var minToFillData = minYIndexOfNeighbors > 0 ? minYIndexOfNeighbors - 1 : minYIndexOfNeighbors
            if extendToFloor {
                minToFillData = 0
            }

            // The maximum value extends to up to 2 above the YIndex to ensure that we can generate correct
            // surfaces. Because the YIndex is using a floor value, and there are crazy rounding issues with math,
            // we extend to 2 instead of 1 additional layer.
            var maxToFillData = maxYIndexOfNeighbors < (maxVoxelIndex - 1) ? maxYIndexOfNeighbors + 1 : maxYIndexOfNeighbors
            if maxToFillData < (maxVoxelIndex - 1) { maxToFillData += 1 }

            // now we calculate the distance-to-surface values for the column extending from minToFillData to maxToFillData
            // There are three ranges that we can consider:
            // - above the range of the neighbors
            // - in the range of the neighbors
            // - below the range of the neighbors
            //
            // When in the range of the neighbors, use an approximation of the distance to the line between
            // the existing point (x,y,z) and a line between the surface point for this column and its
            // neighbor. We take the minimum value to accommodate the shortest distance potentially being the
            // walls that exist in variations within the ranges.
            //
            // We can short-cut this a bit when the index position is the same as the surface index and just use
            // the distance value there directly.
            //
            // When above or below the range, that approximation breaks down (sometimes badly) and instead we
            // should be choosing the shortest distance to the surface points.
            for y in minToFillData ... maxToFillData {
                if y == 0 {
                    assert(true)
                }
                if y == yIndex {
                    // MARK: distance at Y

                    // for the first index value that goes negative, set it only looking at the vertical values
                    voxels[VoxelIndex(xzPosition.x, y, xzPosition.z)] = SDFValueAtHeight(value, at: y, maxVoxelIndex: maxVoxelIndex, voxelSize: voxelSize)
                } else if y < minYIndexOfNeighbors || y > maxYIndexOfNeighbors {
                    // MARK: distance above or below Y range of neighbors

                    // the distance directly "down" or "up"
                    let verticalSDFDistance: Float = SDFValueAtHeight(value, at: y, maxVoxelIndex: maxVoxelIndex, voxelSize: voxelSize)
                    let sizedDistances: [Float] = surroundingNeighbors.compactMap { neighborXZ in

                        let point = sizedPositionOfCenter(xz: xzPosition, y: y, voxelSize: voxelSize)

                        let neighborUnitHeight = heightmap[neighborXZ]
                        let surfacePoint = sizedSurfaceLocation(xz: neighborXZ, unitHeight: neighborUnitHeight, maxVoxelIndex: maxVoxelIndex, voxelSize: voxelSize)
                        let distance = (point - surfacePoint).length
                        if y <= yIndex {
                            return -distance
                        }
                        return distance
                    }
                    let closest = SDFDistanceClosestToSurface(initial: verticalSDFDistance, values: sizedDistances)
                    voxels[VoxelIndex(xzPosition.x, y, xzPosition.z)] = closest
                } else {
                    // MARK: distance inside Y range of neighbors

                    // value is the unit-height at THIS XZ index
                    let verticalSDFDistance: Float = SDFValueAtHeight(value, at: y, maxVoxelIndex: maxVoxelIndex, voxelSize: voxelSize)
                    // get a list of the distances to a line drawn to the surface for each of the neighbors
                    let sizedDistances: [Float] = surroundingNeighbors.compactMap { xzForNeighbor in
                        // exclude the line-estimate estimation if the height map value for this X,Z index
                        // is LESS than the current value. The closest point in the direction where that edge drops away will be the vertical distance to the point directly beneath.
                        // Its more relevant want there's a point significantly higher, in which case the "wall"
                        // surface to this centroid may be closer than the vertical distance.
                        let neighborUnitHeight = heightmap[xzForNeighbor]
                        if neighborUnitHeight >= value {
                            // neighbor
                            // XZ \/
                            // +---+  +---+  +---+
                            // | 2 |  | p |  |   | <- y
                            // +---+  +---+  +---+
                            // +---+  +---+  +---+
                            // |   |  |   |  |   |
                            // +---+  +---+  +---+
                            // +---+  +---+  +---+
                            // |   |  | 1 |  |   | <-- surface height
                            // +---+  +---+  +---+
                            //          ^
                            //      xzPosition

                            // the point is the center of the voxel where we want the SDF value
                            let point = sizedPositionOfCenter(xz: xzPosition, y: y, voxelSize: voxelSize)

                            // the line start is the height value (mapped to voxel size) in this column
                            let lineStart = sizedSurfaceLocation(xz: xzPosition, unitHeight: value, maxVoxelIndex: maxVoxelIndex, voxelSize: voxelSize)
                            // which extends to the height value (mapped to voxel size) in the neighbor column
                            let lineEnd = sizedSurfaceLocation(xz: xzForNeighbor, unitHeight: neighborUnitHeight, maxVoxelIndex: maxVoxelIndex, voxelSize: voxelSize)
                            let computedDistance = distanceFromPointToLine(p: point, x1: lineStart, x2: lineEnd)
                            if y <= yIndex {
                                return -computedDistance
                            }
                            return computedDistance
                        } else {
                            return nil
                        }
                    }
                    // now we want the distance closest to zero
                    let closest = SDFDistanceClosestToSurface(initial: verticalSDFDistance, values: sizedDistances)
                    voxels[VoxelIndex(xzPosition.x, y, xzPosition.z)] = closest
                }
            }
        }
        // ensure that the bounds of the voxels matches the provided maxVoxelHeight, even if nothing
        // gets written near the top of those bounds.
        voxels.bounds = voxels.bounds.adding(VoxelIndex(x: 0, y: maxVoxelIndex, z: 0))
        return voxels
    }
}
