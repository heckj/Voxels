import Heightmap

public enum HeightmapConverter {
    /// Returns the unit value of the center of the voxel at the height index you provide.
    ///
    /// For example, for a set of voxels with a maximum height of `5`:
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
        Float(heightIndex) / Float(maxVoxelIndex - 1)
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
    /// For example, for a set of voxels with a maximum height of `5`, and a unit-height of `0.33`:
    /// ```       unit-value   SDF
    ///           at center   value
    ///    +---
    ///  4 | .  --> 1.00 ...  0.66
    ///    +---
    ///  3 | .  --> 0.75 ...  0.33
    ///    +---
    ///  2 | .  --> 0.50 ...  0.17
    ///    +---
    ///  1 | .  --> 0.25 ... -0.07
    ///    +---
    ///  0 | .  --> 0.00 ... -0.33
    ///    +---
    /// ```
    @inlinable
    static func SDFValueAtHeight(_ unitValue: Float, at y: Int, maxVoxelIndex: Int, voxelSize: Float) -> Float {
        // get unit centroid value of this index
        let centroidFloatOfYIndex = unitCentroidValue(y, maxVoxelIndex: maxVoxelIndex)
        // compute the unit difference
        let difference = centroidFloatOfYIndex - unitValue
        // scale the difference by the size of each voxel to get the final SDF value
        return difference * voxelSize
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
    public static func heightmap(from v: VoxelHash<Float>) -> Heightmap {
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
                let unitFloatAtCenterOfIndex = unitCentroidValue(highestNegativeSDFYIndex, maxVoxelIndex: v.bounds.max.y)
                unitHeightMap.append(SDFValueAtIndex + unitFloatAtCenterOfIndex)
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
                                 voxelSize: Float) -> VoxelHash<Float>
    {
        precondition(heightmap.width > 0)

        var voxels = VoxelHash<Float>(defaultVoxel: 1.0)
        for (stride, value) in heightmap.enumerated() {
            // get the X and Z coordinate index for this column of voxels from the height map
            let xzPosition = XZIndex.strideToXZ(stride, width: heightmap.width)

            // compute a list of the valid neighbor X and Z coordinates that are within the bounds
            // of the height map
            let surroundingNeighbors: [XZIndex] = twoDIndexNeighborsFrom(position: xzPosition, widthCount: heightmap.width, depthCount: heightmap.height)

            // get a list of the VoxelIndex positions of the surface for the neighbor voxel columns
            let neighborsSurfaceVoxelIndex: [VoxelIndex] = surroundingNeighbors.map { xz in
                let yIndexForNeighbor = indexOfSurface(xz, heightmap: heightmap, maxVoxelIndex: maxVoxelIndex)
                return VoxelIndex(xz.x, yIndexForNeighbor, xz.z)
            }

            let yIndex = indexOfSurface(value, maxVoxelIndex: maxVoxelIndex)

            var minYIndexOfNeighbors: Int = neighborsSurfaceVoxelIndex.reduce(yIndex) { partialResult, vIndex in
                Swift.min(partialResult, vIndex.y)
            }
            var maxYIndexOfNeighbors: Int = neighborsSurfaceVoxelIndex.reduce(yIndex) { partialResult, vIndex in
                Swift.max(partialResult, vIndex.y)
            }
            // expand up and down, within the constraints of the voxel hash bounds set by maxVoxelHeight
            // maxVoxelHeight of 6 means indices 0, 1, 2, 3, 4, and 5 are valid, but not -1 or 6
            if minYIndexOfNeighbors > 0 { minYIndexOfNeighbors -= 1 }
            if maxYIndexOfNeighbors < (maxVoxelIndex - 1) { maxYIndexOfNeighbors += 1 }

            // now we calculate the distance-to-surface values for the column extending from minYIndex to maxYIndex
            // To do so, we use the approximation of the distance to the line between the existing point (x,y,z) and the surface index point for each neighbor - taking the minimum value.
            // this distance value is in "unit voxel index" though, so we multiply by the voxel cube
            // height to get it normalized - 1/maxVoxelHeight

            for y in minYIndexOfNeighbors ... maxYIndexOfNeighbors {
                if y == yIndex {
                    // for the first index value that goes negative, set it only looking at the vertical values
                    voxels[VoxelIndex(xzPosition.x, y, xzPosition.z)] = SDFValueAtHeight(value, at: y, maxVoxelIndex: maxVoxelIndex, voxelSize: voxelSize)
                } else {
                    let verticalSDFDistance: Float = SDFValueAtHeight(value, at: y, maxVoxelIndex: maxVoxelIndex, voxelSize: voxelSize)
                    // get a list of the distances to a line drawn to the surface for each of the neighbors
                    let distances: [Float] = surroundingNeighbors.map { neighborXZIndex in
                        // the point is the center of the voxel where we want the SDF value
                        let point = SIMD3<Float>(Float(xzPosition.x), unitCentroidValue(y, maxVoxelIndex: maxVoxelIndex), Float(xzPosition.z))
                        // the line start is the height value in this volume
                        let lineStart = SIMD3<Float>(Float(xzPosition.x), value, Float(xzPosition.z))
                        // which extends to the SDF value in the neighboring column
                        let lineEnd = SIMD3<Float>(x: Float(xzPosition.x - neighborXZIndex.x) * voxelSize,
                                                   y: heightmap[XZIndex(x: neighborXZIndex.x, z: neighborXZIndex.z)],
                                                   z: Float(xzPosition.z - neighborXZIndex.z) * voxelSize)
                        return distanceFromPointToLine(p: point, x1: lineStart, x2: lineEnd)
                    }
                    // now we want the distance closest to zero
                    voxels[VoxelIndex(xzPosition.x, y, xzPosition.z)] = SDFDistanceClosestToSurface(initial: verticalSDFDistance, values: distances)
                }
            }
        }
        // ensure that the bounds of the voxels matches the provided maxVoxelHeight, even if nothing
        // gets written near the top of those bounds.
        voxels.bounds = voxels.bounds.adding(VoxelIndex(x: 0, y: maxVoxelIndex, z: 0))
        return voxels
    }
}
