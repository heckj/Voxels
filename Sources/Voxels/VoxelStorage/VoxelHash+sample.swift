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

    static func clampedSurroundingIndexValues(_ value: Int, min: Int, max: Int) -> [Int] {
        let initialValues: [Int] = [value - 1, value, value + 1]
        return initialValues.filter { i in
            i >= min && i <= max
        }
    }

    // heightmap 0...1 - unit-values
    static func sample(_ heightmap: [[Float]],
                       maxVoxelHeight: Int,
                       scale _: VoxelScale<Float>) -> VoxelHash<Float> where T == Float
    {
        let heightmapSize = sizeOfHeightmap(heightmap)
        var voxels = VoxelHash<Float>()
        for (xIndex, row) in heightmap.enumerated() {
            for (zIndex, value) in row.enumerated() {
                let yIndex = unitSurfaceIndexValue(x: xIndex, y: zIndex, heightmap: heightmap, maxHeight: 12)

                for y in clampedSurroundingIndexValues(yIndex, min: 0, max: maxVoxelHeight) {
                    voxels[VoxelIndex(xIndex, y, zIndex)] = unitCentroidValue(y, max: maxVoxelHeight) - value
                }
                // this might be better interpolating to the voxel index positions +/- 1 to each of the neighbors
                // for each voxel in a surfaceNet, we'd ideally want the value to the surface... which I guess
                // is most easily approximated by the smallest distance to the surface values in each
                // of the neighboring voxels.
            }
        }
        // TODO: If there's large vertical changes between values, this won't properly fill in the gaps.
        return voxels
    }
}
