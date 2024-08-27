import RealityKit
import Voxels

enum EntityExample {
    private static func into_domain(array_dim: UInt, _ xyz: VoxelIndex) -> SIMD3<Float> {
        // samples over a quadrant - starts at -1 and goes up to (2/edgeSize * (edgeSize-1)) - 1
        (2.0 / Float(array_dim)) * SIMD3<Float>(Float(xyz.x), Float(xyz.y), Float(xyz.z)) - 1.0
    }

    static func sampledSDFSphere() -> VoxelArray<Float> {
        let sphereSDF: SDFSampleable<Float> = SDF.sphere()
        var samples = VoxelArray<Float>(edge: 34, value: 0.0)

        do {
            for i in 0 ..< samples.bounds.size {
                let voxelIndex = try samples.bounds.delinearize(i)
                let position: SIMD3<Float> = into_domain(array_dim: 32, voxelIndex)
                let valueAtPosition = sphereSDF.valueAt(position)
                try samples.set(voxelIndex, newValue: valueAtPosition)
            }
        } catch {
            fatalError("Issue while sampling SDF into a voxel array: \(error)")
        }
        return samples
    }

    static func oneByOne() -> VoxelHash<Float> {
        var voxels = VoxelHash<Float>()
        voxels.set(VoxelIndex(2, 2, 2), newValue: -1.0)
        return voxels
    }

    static func threeByThree() -> VoxelHash<Float> {
        var threeByThree = VoxelHash<Float>()
        // create cube in the middle
        for i in 1 ... 3 {
            for j in 1 ... 3 {
                for k in 1 ... 3 {
                    threeByThree.set(VoxelIndex(i, j, k), newValue: -1.0)
                }
            }
        }
        return threeByThree
    }

    static func manhattanNeighbor1() -> VoxelHash<Float> {
        var voxels = threeByThree()
        voxels.set(VoxelIndex(2, 2, 2), newValue: -1)

        voxels.set(VoxelIndex(1, 2, 2), newValue: -1)
        voxels.set(VoxelIndex(3, 2, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 1, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 3, 2), newValue: -1)
        voxels.set(VoxelIndex(2, 2, 1), newValue: -1)
        voxels.set(VoxelIndex(2, 2, 3), newValue: -1)
        return voxels
    }

    static var surfaceNet: ModelEntity {
        let samples = sampledSDFSphere()
        do {
            let buffer = try VoxelMeshRenderer.surfaceNetMesh(
                sdf: samples,
                within: VoxelBounds(
                    min: VoxelIndex(0, 0, 0),
                    max: VoxelIndex(32, 32, 32)
                )
            )

            let descriptor = buffer.meshDescriptor()
            let mesh = try! MeshResource.generate(from: [descriptor])
            let material = SimpleMaterial(color: .green, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.name = "surfaceNet"
            return entity
        } catch {
            fatalError("Issue while rendering surface-net mesh: \(error)")
        }
    }

    static var fastSurfaceBlockMesh: ModelEntity {
        let samples = sampledSDFSphere()
        let buffer = VoxelMeshRenderer.fastBlockMesh(samples, scale: .init())

        let descriptor = buffer.meshDescriptor()
        let mesh = try! MeshResource.generate(from: [descriptor])
        let material = SimpleMaterial(color: .green, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "fastSurfaceBlock"
        return entity
    }
}
