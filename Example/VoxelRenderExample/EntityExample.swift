import RealityKit
import Voxels

enum EntityExample {
    private static func into_domain(array_dim: UInt, _ xyz: SIMD3<Int>) -> SIMD3<Float> {
        // samples over a quadrant - starts at -1 and goes up to (2/edgeSize * (edgeSize-1)) - 1
        (2.0 / Float(array_dim)) * SIMD3<Float>(Float(xyz.x), Float(xyz.y), Float(xyz.z)) - 1.0
    }

    static var surfaceNet: ModelEntity {
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

        do {
            let buffer = try VoxelMeshRenderer.surfaceNetMesh(
                sdf: samples,
                within: VoxelBounds(
                    min: VoxelIndex(0, 0, 0),
                    max: VoxelIndex(33, 33, 33)
                )
            )

            let descriptor = buffer.meshDescriptor()
            let mesh = try! MeshResource.generate(from: [descriptor])
            let material = SimpleMaterial(color: .green, isMetallic: false)
            return ModelEntity(mesh: mesh, materials: [material])
        } catch {
            fatalError("Issue while rendering surface-net mesh: \(error)")
        }
    }

    static var fastSurfaceBlockMesh: ModelEntity {
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

        let buffer = VoxelMeshRenderer.fastBlockMesh(samples, scale: .init())

        let descriptor = buffer.meshDescriptor()
        let mesh = try! MeshResource.generate(from: [descriptor])
        let material = SimpleMaterial(color: .green, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
}
