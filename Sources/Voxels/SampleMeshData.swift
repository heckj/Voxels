public enum SampleMeshData {
    public static func voxelArrayFromSphere() throws -> VoxelArray<Float> {
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

    public static func manhattanNeighbor1() -> VoxelHash<Float> {
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

    public static func flatYBlock() -> VoxelHash<Float> {
        var flatVoxelBlock = VoxelHash<Float>(defaultVoxel: Float.greatestFiniteMagnitude)
        // create cube in the middle
        let bounds = VoxelBounds(min: VoxelIndex(0, 2, 0), max: VoxelIndex(9, 2, 9))
        for i in 0 ..< bounds.size {
            flatVoxelBlock.set(try! bounds.delinearize(i), newValue: -1.0)
        }
        return flatVoxelBlock
    }

    public static func SDFBrick() -> VoxelHash<Float> {
        var voxels = VoxelHash(defaultVoxel: Float.greatestFiniteMagnitude)
        // < 0 : inside surface (distance to)
        // 0 : at surface
        // > 0 : outside surface (distance to)
        // voxels are measured at the centroid of their space

        let layer0values: [[Float]] = [
            [1.5, 1.0, 1.0, 1.0, 1.5],
            [1.0, 0.0, 0.0, 0.0, 1.0],
            [1.0, 0.0, -1.0, 0.0, 1.0],
            [1.0, 0.0, -1.0, 0.0, 1.0],
            [1.0, 0.0, -1.0, 0.0, 1.0],
            [1.0, 0.0, -1.0, 0.0, 1.0],
            [1.0, 0.0, -1.0, 0.0, 1.0],
            [1.0, 0.0, 0.0, 0.0, 1.0],
            [1.5, 1.0, 1.0, 1.0, 1.5],
        ]
        for z in 0 ..< layer0values.count {
            for x in 0 ..< layer0values[z].count {
                voxels.set(VoxelIndex(x, 1, z), newValue: layer0values[z][x])
            }
        }
        let layer1values: [[Float]] = [
            [1.5, 1.0, 1.0, 1.0, 1.5],
            [1.0, 0.5, 0.5, 0.5, 1.0],
            [1.0, 0.5, -0.5, 0.5, 1.0],
            [1.0, 0.5, -0.5, 0.5, 1.0],
            [1.0, 0.5, -0.5, 0.5, 1.0],
            [1.0, 0.5, -0.5, 0.5, 1.0],
            [1.0, 0.5, -0.5, 0.5, 1.0],
            [1.0, 0.5, 0.5, 0.5, 1.0],
            [1.5, 1.0, 1.0, 1.0, 1.5],
        ]
        for z in 0 ..< layer1values.count {
            for x in 0 ..< layer1values[z].count {
                voxels.set(VoxelIndex(x, 2, z), newValue: layer1values[z][x])
            }
        }
        return voxels
    }
}