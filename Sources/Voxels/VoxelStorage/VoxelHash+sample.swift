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

    static func sizeOfHeightmap(_ map: [[Float]]) -> (height: Int, width: Int) {
        let height = map.count
        let width = map.reduce(into: 0) { partialResult, row in
            partialResult = Swift.max(partialResult, row.count)
        }
        return (height: height, width: width)
    }

    static func twoDIndexNeighborsFrom(x: Int, y: Int, widthCount: Int, heightCount: Int) -> [(x: Int, y: Int)] {
        var returns: [(x: Int, y: Int)] = []
        for possibleX in x - 1 ... x + 1 {
            for possibleY in y - 1 ... y + 1 {
                if possibleX >= 0, possibleX < widthCount, possibleY >= 0, possibleY < heightCount {
                    returns.append((x: possibleX, y: possibleY))
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

    // heightmap 0...1 - unit-values
    static func sample(_ heightmap: [[Float]],
                       maxVoxelHeight: Int,
                       scale _: VoxelScale<Float>) -> VoxelHash<Float> where T == Float
    {
        let heightmapSize = sizeOfHeightmap(heightmap)
        var voxels = VoxelHash<Float>()
        for (xIndex, row) in heightmap.enumerated() {
            for (zIndex, _) in row.enumerated() {
                let surroundingNeighbors: [(x: Int, y: Int)] = twoDIndexNeighborsFrom(x: xIndex, y: zIndex, widthCount: heightmapSize.width, heightCount: heightmapSize.height)

                let neighborsSurfaceVoxelIndex: [VoxelIndex] = surroundingNeighbors.map { xy in
                    let yIndexForNeighbor = unitSurfaceIndexValue(x: xy.x, y: xy.y, heightmap: heightmap, maxHeight: maxVoxelHeight)
                    return VoxelIndex(xy.x, yIndexForNeighbor, xy.y)
                }

                let yIndex = unitSurfaceIndexValue(x: xIndex, y: zIndex, heightmap: heightmap, maxHeight: maxVoxelHeight)

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
                        pointdistancetoline(p: SIMD3<Float>(Float(xIndex), Float(y), Float(zIndex)),
                                            // line from the the surface index point of this column
                                            x1: SIMD3<Float>(Float(xIndex), Float(yIndex), Float(zIndex)),
                                            // to the surface index point of the neighbor
                                            x2: SIMD3<Float>(Float(vi.x), Float(vi.y), Float(vi.z)))
                    }
                    let minDistance = distances.min() ?? 0
                    let minDistanceMappedBack = minDistance / Float(maxVoxelHeight)
                    // damn, this isn't given me the signed distance - I don't know if I'm inside or outside
                    // of that line!

                    // I *think* I can determine a sign by if I'm over or under the current surface index
                    if y > yIndex {
                        voxels[VoxelIndex(xIndex, y, zIndex)] = minDistanceMappedBack
                    } else {
                        // if y == yIndex ...
                        // TODO(heckj): This may not be correct sign
                        voxels[VoxelIndex(xIndex, y, zIndex)] = -minDistanceMappedBack
                    }
                }
            }
        }
        return voxels
    }
}
