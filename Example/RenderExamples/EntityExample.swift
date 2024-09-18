import Heightmap
import RealityKit
import Voxels

public enum EntityExample {
    private static func into_domain(array_dim: UInt, _ xyz: VoxelIndex) -> SIMD3<Float> {
        // samples over a quadrant - starts at -1 and goes up to (2/edgeSize * (edgeSize-1)) - 1
        (2.0 / Float(array_dim)) * SIMD3<Float>(Float(xyz.x), Float(xyz.y), Float(xyz.z)) - 1.0
    }

    public static func sampledSDFSphere() -> VoxelArray<Float> {
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

    public static func oneByOne() -> VoxelHash<Float> {
        var voxels = VoxelHash<Float>()
        voxels.set(VoxelIndex(2, 2, 2), newValue: -1.0)
        return voxels
    }

    public static func threeByThree() -> VoxelHash<Float> {
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

    public static var surfaceNetSphere: ModelEntity {
        let samples = sampledSDFSphere()
        do {
            let renderer = SurfaceNetRenderer()
            let buffer = try! renderer.render(voxelData: samples, scale: .init(), within: samples.bounds.insetQuadrant())

            if let descriptor = buffer.meshDescriptor() {
                let mesh = try MeshResource.generate(from: [descriptor])
                let material = SimpleMaterial(color: .green, isMetallic: false)
                let entity = ModelEntity(mesh: mesh, materials: [material])
                entity.name = "surfaceNet"
                return entity
            }
        } catch {
            fatalError("Issue while rendering surface-net mesh: \(error)")
        }
        fatalError("Issue while rendering surface-net mesh: Empty Buffer")
    }

    public static var fastSurfaceBlockMeshSphere: ModelEntity {
        let samples = sampledSDFSphere()
        let buffer = BlockMeshRenderer().render(samples, scale: .init(), within: samples.bounds.insetQuadrant())

        if let descriptor = buffer.meshDescriptor() {
            let mesh = try! MeshResource.generate(from: [descriptor])
            let material = SimpleMaterial(color: .green, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.name = "fastSurfaceBlock"
            return entity
        }
        fatalError("Issue while rendering surface-net mesh: Empty Buffer")
    }

    public static var surfaceNetBrick: ModelEntity {
        let voxels = Voxels.SampleMeshData.SDFBrick()
        let renderer = SurfaceNetRenderer()
        let generatedMeshBuffer = try! renderer.render(voxelData: voxels, scale: .init(), within: voxels.bounds.expand(2))

        guard let descriptor = generatedMeshBuffer.meshDescriptor() else {
            fatalError("Invalid mesh - no descriptor")
        }
        let mesh = try! MeshResource.generate(from: [descriptor])
        let material = SimpleMaterial(color: .green, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "SDFBrick"
        return entity
    }

    public static var flatYBlock: ModelEntity {
        let voxels = Voxels.SampleMeshData.flatYBlock()
        let renderer = SurfaceNetRenderer()
        let generatedMeshBuffer = try! renderer.render(voxelData: voxels, scale: .init(), within: voxels.bounds.expand(2))

        guard let descriptor = generatedMeshBuffer.meshDescriptor() else {
            fatalError("Invalid mesh - no descriptor")
        }
        let mesh = try! MeshResource.generate(from: [descriptor])
        let material = SimpleMaterial(color: .green, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "flatYBlock"
        return entity
    }

    public static var marchingCubesHeightmap: ModelEntity {
        let heightmap = Heightmap(width: 100, height: 100, seed: 437_347_632)

        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 20, voxelSize: 1.0)
        let buffer = MarchingCubesRenderer().render(voxels, scale: .init(), within: voxels.bounds.expand())
        guard let descriptor = buffer.meshDescriptor() else {
            fatalError()
        }
        let mesh = try! MeshResource.generate(from: [descriptor])
        let material = SimpleMaterial(color: .brown, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }

    public static var surfaceNetHeightmap: ModelEntity {
        let heightmap = Heightmap(width: 100, height: 100, seed: 437_347_632)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 20, voxelSize: 1.0, extendToFloor: true)
        let buffer = try! SurfaceNetRenderer().render(voxelData: voxels,
                                                      scale: .init(),
                                                      within: voxels.bounds)
        guard let descriptor = buffer.meshDescriptor() else {
            fatalError()
        }
        let mesh = try! MeshResource.generate(from: [descriptor])
        let material = SimpleMaterial(color: .brown, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }

    public static var surfaceBlockHeightmap: ModelEntity {
        let heightmap = Heightmap(width: 100, height: 100, seed: 437_347_632)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 20, voxelSize: 1.0, extendToFloor: true)
        let buffer = BlockMeshRenderer().render(voxels,
                                                scale: .init(),
                                                within: voxels.bounds,
                                                surfaceOnly: true)
        guard let descriptor = buffer.meshDescriptor() else {
            fatalError()
        }
        let mesh = try! MeshResource.generate(from: [descriptor])
        let material = SimpleMaterial(color: .brown, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
}
