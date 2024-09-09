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

    static func lookupUnitSurfaceIndexValue(x: Int, z: Int, heightmap: [Float], width: Int, maxHeight: Int) -> Int {
        let stride = XZtoStride(x: x, z: z, width: width)
        let value = heightmap[stride]
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

    static func flattenAndCheck(_ heightmap: [[Float]]) throws -> ([Float], Int, Int) {
        let heightmapSize = sizeOfHeightmap(heightmap)
        let flattened = Array(heightmap.joined())
        // check
        if heightmapSize.height * heightmapSize.width != flattened.count {
            throw HeightmapError.invalid("provided 2D array is irregular - \(heightmapSize.height) * \(heightmapSize.width) != \(flattened.count)")
        }
        return (flattened, heightmapSize.width, heightmapSize.height)
    }

    struct XZIndex: Sendable, Hashable {
        let x: Int
        let z: Int

        public init(x: Int, z: Int) {
            self.x = x
            self.z = z
        }
    }

    @inlinable
    static func strideToXZ(_ stride: Int, width: Int) -> XZIndex {
        var z = 0
        if stride > (width - 1) {
            z = stride / width
        }
        let remaining = stride - (z * width)
        return XZIndex(x: remaining, z: z)
    }

    @inlinable
    static func XZtoStride(x: Int, z: Int, width: Int) -> Int {
        let minorOffset = z * width
        return minorOffset + x
    }

    // heightmap 0...1 - unit-values
    static func heightmap(_ heightmap: [[Float]],
                          maxVoxelHeight: Int,
                          scale: VoxelScale<Float>) -> VoxelHash<Float> where T == Float
    {
        let flattened = try! flattenAndCheck(heightmap)
        return Self.heightmap(flattened.0, width: flattened.1, maxVoxelHeight: maxVoxelHeight, scale: scale)
    }

    static func heightmap(_ heightmap: [Float],
                          width: Int,
                          maxVoxelHeight: Int,
                          scale _: VoxelScale<Float>) -> VoxelHash<Float> where T == Float
    {
        precondition(width > 0)
        precondition(heightmap.count % width == 0, "heightmap array of \(heightmap.count) is not directly divisible by \(width)")

        let heightmapSize: (height: Int, width: Int) = (heightmap.count / width, width)
        var voxels = VoxelHash<Float>()
        for (stride, value) in heightmap.enumerated() {
            let xzPosition: XZIndex = strideToXZ(stride, width: width)

            let surroundingNeighbors: [(x: Int, z: Int)] = twoDIndexNeighborsFrom(x: xzPosition.x, z: xzPosition.z, widthCount: heightmapSize.width, heightCount: heightmapSize.height)

            let neighborsSurfaceVoxelIndex: [VoxelIndex] = surroundingNeighbors.map { xy in
                let yIndexForNeighbor = lookupUnitSurfaceIndexValue(x: xy.x, z: xy.z, heightmap: heightmap, width: width, maxHeight: maxVoxelHeight)
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
        return voxels
    }
}
