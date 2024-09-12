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
    static func unitCentroidValue(_ heightIndex: Int, maxHeight: Int) -> Float {
        Float(heightIndex) / Float(maxHeight - 1)
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
    static func SDFValueAtHeight(_ unitValue: Float, at y: Int, maxVoxelHeight: Int, voxelSize: Float) -> Float {
        // get unit centroid value of this index
        let centroidFloatOfYIndex = unitCentroidValue(y, maxHeight: maxVoxelHeight)
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
    static func indexOfSurface(_ p: XZIndex, heightmap: Heightmap, maxHeight: Int) -> Int {
        let mappedUnitHeightValue = heightmap[p] * Float(maxHeight - 1)
        // convert 0...1 -> 0...(maxVoxelHeight - 1)

        let yIndex = Int(mappedUnitHeightValue.rounded(.towardZero))
        // loosely equiv to floor() - gets the lower index position for the voxel Index

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

    /// Computes a height map from the collection of voxels.
    ///
    /// If a coordinate location has no voxels, the height map value is returned as 0.
    /// - Returns: A height map of the highest surface represented in the voxels SDF values.
    public static func heightmap(from v: VoxelHash<Float>) -> Heightmap {
        let width = (v.bounds.max.x - v.bounds.min.x) + 1
        let heightmapSize = width * (v.bounds.max.z - v.bounds.min.z + 1)

        var unitHeightMap: [Float] = []
        let voxelUnitHeight: Float = 1.0 / Float(v.bounds.max.y - v.bounds.min.y)

        for linearIndexStep in 0 ..< heightmapSize {
            let xz = XZIndex.strideToXZ(linearIndexStep, width: width)
            let yIndicesToCheckInOrder: [Int] = (v.bounds.min.y ... v.bounds.max.y).reversed()
            let highestNegativeSDFYIndex: Int? = yIndicesToCheckInOrder.first(where: { yToCheck in
                if let value = v[VoxelIndex(xz.x, yToCheck, xz.z)] {
                    return value <= 0
                }
                return false
            })
            if let highestNegativeSDFYIndex {
                unitHeightMap.append(voxelUnitHeight * Float(highestNegativeSDFYIndex) + voxelUnitHeight / 2.0)
            } else {
                unitHeightMap.append(0.0)
            }
        }
        return Heightmap(unitHeightMap, width: width)
    }

    /// Creates a collection of Voxels from a height map
    /// - Parameters:
    ///   - heightmap: The Heightmap that represents the relative height at each x and z voxel index.
    ///   - maxVoxelHeight: The maximum height of voxels.
    public static func heightmap(_ heightmap: Heightmap,
                                 maxVoxelHeight: Int) -> VoxelHash<Float>
    {
        precondition(heightmap.width > 0)

        var voxels = VoxelHash<Float>(defaultVoxel: 1.0)
        for (stride, value) in heightmap.enumerated() {
            let xzPosition = XZIndex.strideToXZ(stride, width: heightmap.width)

            let surroundingNeighbors: [XZIndex] = twoDIndexNeighborsFrom(position: xzPosition, widthCount: heightmap.width, depthCount: heightmap.height)

            let neighborsSurfaceVoxelIndex: [VoxelIndex] = surroundingNeighbors.map { xz in
                let yIndexForNeighbor = indexOfSurface(xz, heightmap: heightmap, maxHeight: maxVoxelHeight)
                return VoxelIndex(xz.x, yIndexForNeighbor, xz.z)
            }

            // convert value of 0...1 to index position of 0...maxVoxelHeight
            let yIndex = Int(value * Float(maxVoxelHeight).rounded(.towardZero))

            var minYIndex: Int = neighborsSurfaceVoxelIndex.reduce(yIndex) { partialResult, vIndex in
                Swift.min(partialResult, vIndex.y)
            }
            var maxYIndex: Int = neighborsSurfaceVoxelIndex.reduce(yIndex) { partialResult, vIndex in
                Swift.max(partialResult, vIndex.y)
            }
            // expand up and down, within the constraints of the voxel hash bounds set by maxVoxelHeight
            // maxVoxelHeight of 6 means indices 0, 1, 2, 3, 4, and 5 are vald, but not -1 or 6
            if minYIndex > 0 { minYIndex -= 1 }
            if maxYIndex < (maxVoxelHeight - 2) { maxYIndex += 1 }

            // now we calculate the distance-to-surface values for the column extending from minYIndex to maxYIndex
            // To do so, we use the approximation of the distance to the line between the existing point (x,y,z) and the surface index point for each neighbor - taking the minimum value.
            // this distance value is in "unit voxel index" though, so we multiply by the voxel cube
            // height to get it normalized - 1/maxVoxelHeight

            for y in minYIndex ... maxYIndex {
                let distances: [Float] = neighborsSurfaceVoxelIndex.map { vi in
                    distanceFromPointToLine(p: SIMD3<Float>(Float(xzPosition.x), Float(y), Float(xzPosition.z)),
                                            // line from the the surface index point of this column
                                            x1: SIMD3<Float>(Float(xzPosition.x), Float(yIndex), Float(xzPosition.z)),
                                            // to the surface index point of the neighbor
                                            x2: SIMD3<Float>(Float(vi.x), Float(vi.y), Float(vi.z)))
                }
                let minDistance = distances.min() ?? 0
                let minDistanceMappedBack = minDistance / Float(maxVoxelHeight)
                // damn, this isn't given me the signed distance - I don't know if I'm inside or outside
                // of that line!

                // I *think* I can determine a sign by if I'm over or under the current surface index
                if y > yIndex {
                    voxels[VoxelIndex(xzPosition.x, y, xzPosition.z)] = minDistanceMappedBack
                } else {
                    // if y == yIndex ...
                    // TODO(heckj): This may not be correct sign
                    voxels[VoxelIndex(xzPosition.x, y, xzPosition.z)] = -minDistanceMappedBack
                }
            }
        }
        voxels.bounds = voxels.bounds.adding(VoxelIndex(x: 0, y: maxVoxelHeight, z: 0))
        return voxels
    }
}