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
}
