import RealityKit
import Spatial
import Voxels

#if os(macOS)
    func establishCamera(_ arView: ARView, at camera_position: Point3D, lookingAt: Point3D) {
        // Establish an explicit camera for the scene
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 60
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(cameraEntity)
        arView.scene.addAnchor(cameraAnchor)
        // position the camera
        let lookRotation = Rotation3D(position: lookingAt,
                                      target: camera_position,
                                      up: Vector3D(x: 0, y: 1, z: 0))
        cameraAnchor.transform = Transform(scale: .one, rotation: simd_quatf(lookRotation), translation: SIMD3<Float>(camera_position))
    }

    func addEntity(_ entity: ModelEntity, to arView: ARView) {
        let originAnchor = AnchorEntity(world: .zero)
        originAnchor.addChild(entity)
        arView.scene.anchors.append(originAnchor)
    }

    func blockMeshEntity(_ samples: some VoxelAccessible) -> ModelEntity {
        let buffer = BlockMeshRenderer().render(samples, scale: .init(), within: samples.bounds.expand())
        let descriptor = buffer.meshDescriptor()
        let mesh = try! MeshResource.generate(from: [descriptor!])
        let material = SimpleMaterial(color: .green, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        return entity
    }

    func marchingCubesEntity(_ samples: some VoxelAccessible) -> ModelEntity {
        let buffer = MarchingCubesRenderer().render(samples, scale: .init(), within: samples.bounds.expand())
        let descriptor = buffer.meshDescriptor()
        let mesh = try! MeshResource.generate(from: [descriptor!])
        let material = SimpleMaterial(color: .green, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        return entity
    }

    func surfaceNetEntity(_ samples: some VoxelAccessible) -> ModelEntity {
        let buffer = try! SurfaceNetRenderer().render(voxelData: samples, scale: .init(), within: samples.bounds.expand())
        let descriptor = buffer.meshDescriptor()
        let mesh = try! MeshResource.generate(from: [descriptor!])
        let material = SimpleMaterial(color: .green, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        return entity
    }
#endif
