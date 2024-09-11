import Heightmap

public extension VoxelHash {
    static func sample(_ samples: SDFSampleable<Float>,
                       using scale: VoxelScale<Float>,
                       from min: SIMD3<Float>,
                       to max: SIMD3<Float>) -> VoxelHash<Float> where T == Float
    {
        var voxels = VoxelHash<Float>()
        for x in stride(from: min.x, through: max.x, by: scale.cubeSize) {
            for y in stride(from: min.y, through: max.y, by: scale.cubeSize) {
                for z in stride(from: min.z, through: max.z, by: scale.cubeSize) {
                    let position = SIMD3<Float>(Float(x), Float(y), Float(z))
                    let voxelIndex = scale.index(for: position)
                    voxels[voxelIndex] = samples.valueAt(position)
                }
            }
        }
        return voxels
    }

    static func unitCentroidValue(_ index: Int, max: Int) -> Float {
        let step = 1.0 / Float(max)
        return (Float(index) * step) + (step / 2.0)
    }

    static func unitSurfaceIndexValue(x: Int, y: Int, heightmap: [[Float]], maxHeight: Int) -> Int {
        let value = heightmap[y][x]
        let mappedUnitHeightValue = value * Float(maxHeight)
        // convert 0...1 -> 0...maxVoxelHeight

        let yIndex = Int(mappedUnitHeightValue.rounded(.towardZero))
        // loosely equiv to floor() - gets the lower index position for the voxel Index

        return yIndex
    }

    static func lookupUnitSurfaceIndexValue(x: Int, z: Int, heightmap: Heightmap, maxHeight: Int) -> Int {
        let value = heightmap[x, z]
        let mappedUnitHeightValue = value * Float(maxHeight)
        // convert 0...1 -> 0...maxVoxelHeight

        let yIndex = Int(mappedUnitHeightValue.rounded(.towardZero))
        // loosely equiv to floor() - gets the lower index position for the voxel Index

        return yIndex
    }

    static func sizeOfHeightmap(_ map: [[Float]]) -> (height: Int, width: Int) {
        let height = map.count
        let width = map.reduce(into: 0) { partialResult, row in
            partialResult = Swift.max(partialResult, row.count)
        }
        return (height: height, width: width)
    }

    static func twoDIndexNeighborsFrom(x: Int, z: Int, widthCount: Int, heightCount: Int) -> [(x: Int, z: Int)] {
        var returns: [(x: Int, z: Int)] = []
        for possibleX in x - 1 ... x + 1 {
            for possibleZ in z - 1 ... z + 1 {
                if possibleX >= 0, possibleX < widthCount, // bounding possible neighbors by width
                   possibleZ >= 0, possibleZ < heightCount, // bounding possible neighbors by depth
                   !(x == possibleX && z == possibleZ) // don't include the originating position in neighbor list
                {
                    returns.append((x: possibleX, z: possibleZ))
                }
            }
        }
        return returns
    }

    static func pointdistancetoline(p: SIMD3<Float>, x1: SIMD3<Float>, x2: SIMD3<Float>) -> Float {
        // https://mathworld.wolfram.com/Point-LineDistance3-Dimensional.html
        //  | (p - x1) X (x0 - x2) |
        // --------------------------
        //       | (x2 - x1) |
        let top = (p - x1).cross(p - x2)
        let bottom = x2 - x1
        return top.length / bottom.length
    }

    static func flattenAndCheck(_ heightmap: [[Float]]) throws -> Heightmap {
        let heightmapSize = sizeOfHeightmap(heightmap)
        let flattened = Array(heightmap.joined())
        // check
        if heightmapSize.height * heightmapSize.width != flattened.count {
            throw HeightmapError.invalid("provided 2D array is irregular - \(heightmapSize.height) * \(heightmapSize.width) != \(flattened.count)")
        }
        return Heightmap(flattened, width: heightmapSize.width)
    }

    // heightmap 0...1 - unit-values
    static func heightmap(_ heightmap: [[Float]],
                          maxVoxelHeight: Int) -> VoxelHash<Float> where T == Float
    {
        let flattened = try! flattenAndCheck(heightmap)
        return Self.heightmap(flattened, maxVoxelHeight: maxVoxelHeight)
    }

    func heightmap() -> [Float] where T == Float {
        let width = (bounds.max.x - bounds.min.x) + 1
        let heightmapSize = width * (bounds.max.z - bounds.min.z + 1)

        var unitHeightMap: [Float] = []
        let voxelUnitHeight: Float = 1.0 / Float(bounds.max.y - bounds.min.y)

        for linearIndexStep in 0 ..< heightmapSize {
            let xz: XZIndex = Self.strideToXZ(linearIndexStep, width: width)
            let yIndicesToCheckInOrder: [Int] = (bounds.min.y ... bounds.max.y).reversed()
            let highestNegativeSDFYIndex: Int? = yIndicesToCheckInOrder.first(where: { yToCheck in
                if let value = self[VoxelIndex(xz.x, yToCheck, xz.z)] {
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
        return unitHeightMap
    }

    /// Creates a collection of Voxels from a height map
    /// - Parameters:
    ///   - heightmap: The Heightmap that represents the relative height at each x and z voxel index.
    ///   - maxVoxelHeight: The maximum height of voxels.
    static func heightmap(_ heightmap: Heightmap,
                          maxVoxelHeight: Int) -> VoxelHash<Float> where T == Float
    {
        precondition(heightmap.width > 0)

        var voxels = VoxelHash<Float>(defaultVoxel: 1.0)
        for (stride, value) in heightmap.enumerated() {
            let xzPosition = XZIndex.strideToXZ(stride, width: heightmap.width)

            let surroundingNeighbors: [(x: Int, z: Int)] = twoDIndexNeighborsFrom(x: xzPosition.x, z: xzPosition.z, widthCount: heightmap.width, heightCount: heightmap.height)

            let neighborsSurfaceVoxelIndex: [VoxelIndex] = surroundingNeighbors.map { xy in
                let yIndexForNeighbor = lookupUnitSurfaceIndexValue(x: xy.x, z: xy.z, heightmap: heightmap, maxHeight: maxVoxelHeight)
                return VoxelIndex(xy.x, yIndexForNeighbor, xy.z)
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
                    pointdistancetoline(p: SIMD3<Float>(Float(xzPosition.x), Float(y), Float(xzPosition.z)),
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
