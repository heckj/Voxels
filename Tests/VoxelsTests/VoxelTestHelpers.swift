import Voxels

enum VoxelTestHelpers {
    static func voxelArrayFromSphere() throws -> VoxelArray<Float> {
        let sphereSDF: SDFSampleable<Float> = SDF.sphere()
        var samples = VoxelArray<Float>(edge: 34, value: 0.0)

        func into_domain(array_dim: UInt, _ xyz: VoxelIndex) -> SIMD3<Float> {
            // samples over a quadrant - starts at -1 and goes up to (2/edgeSize * (edgeSize-1)) - 1
            (2.0 / Float(array_dim)) * SIMD3<Float>(Float(xyz.x), Float(xyz.y), Float(xyz.z)) - 1.0
        }

        for i in 0 ..< (samples.bounds.size) {
            let voxelIndex = try samples.bounds.delinearize(i)
            let position: SIMD3<Float> = into_domain(array_dim: 32, voxelIndex)
            let value = sphereSDF.valueAt(position)
            try samples.set(voxelIndex, newValue: value)
        }
        return samples
    }

    static func manhattanNeighbor1() -> VoxelHash<Float> {
        var voxels = VoxelHash<Float>()
        voxels.set(VoxelIndex(2, 2, 2), newValue: -1)

        voxels.set(VoxelIndex(1, 2, 2), newValue: -1)
        voxels.set(VoxelIndex(3, 2, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 1, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 3, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 2, 1), newValue: -1)
        voxels.set(VoxelIndex(2, 2, 3), newValue: -1)
        return voxels
    }
}
