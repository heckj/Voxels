import RealityKit
import SwiftUI
import Voxels

#if os(iOS)
    typealias PlatformColor = UIColor
#elseif os(macOS)
    typealias PlatformColor = NSColor
#endif

struct ContentView: View {
    @State private var arcballState: ArcBallState

    private func into_domain(array_dim: UInt, _ xyz: SIMD3<Int>) -> SIMD3<Float> {
        // samples over a quadrant - starts at -1 and goes up to (2/edgeSize * (edgeSize-1)) - 1
        (2.0 / Float(array_dim)) * SIMD3<Float>(Float(xyz.x), Float(xyz.y), Float(xyz.z)) - 1.0
    }

    private func buildMesh() throws -> ModelEntity {
        let sphereSDF: SDFSampleable<Float> = SDF.sphere()
        var samples = VoxelArray<Float>(edge: 34, value: 0.0)

        for i in 0 ..< samples.size {
            let voxelIndex = try samples.delinearize(i)
            let position: SIMD3<Float> = into_domain(array_dim: 32, voxelIndex)
            let valueAtPosition = sphereSDF.valueAt(position)
            try samples.set(voxelIndex, newValue: valueAtPosition)
        }

        let buffer = try surface_nets(
            sdf: samples,
            min: VoxelIndex(0, 0, 0),
            max: VoxelIndex(33, 33, 33)
        )

        let descriptor = buffer.meshDescriptor()
        let mesh = try! MeshResource.generate(from: [descriptor])
        let material = SimpleMaterial(color: .green, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }

    private func showTangentCoordinateSystems(modelEntity: ModelEntity, parent: Entity) {
        let axisLength: Float = 0.02

        for model in modelEntity.model!.mesh.contents.models {
            for part in model.parts {
                var positions: [simd_float3] = []

                for position in part.positions {
                    parent.addChild(buildSphere(position: position, radius: 0.005, color: .black))
                    positions.append(position)
                }

                for (i, tangent) in part.tangents!.enumerated() {
                    parent.addChild(buildSphere(position: positions[i] + (axisLength * tangent), radius: 0.0025, color: .red))
                }

                for (i, bitangent) in part.bitangents!.enumerated() {
                    parent.addChild(buildSphere(position: positions[i] + (axisLength * bitangent), radius: 0.0025, color: .green))
                }

                for (i, normal) in part.normals!.enumerated() {
                    parent.addChild(buildSphere(position: positions[i] + (axisLength * normal), radius: 0.0025, color: .blue))
                }
            }
        }
    }

    private func buildSphere(position: simd_float3, radius: Float, color: PlatformColor) -> ModelEntity {
        let sphereEntity = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])
        sphereEntity.position = position
        return sphereEntity
    }

    private func buildBareQuad(color: PlatformColor) -> ModelEntity {
        var buffer = MeshBuffer()
        buffer.addQuad(p1: SIMD3<Float>(0, 1, 0), p2: SIMD3<Float>(0, 0, 0), p3: SIMD3<Float>(1, 1, 0), p4: SIMD3<Float>(1, 0, 0))
        let descriptor = buffer.meshDescriptor()
        let mesh = try! MeshResource.generate(from: [descriptor])
        let material = SimpleMaterial(color: color, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }

    private func buildFloor(color: PlatformColor) -> ModelEntity {
        let floorEntity = ModelEntity(
            mesh: .generatePlane(width: 1.0, depth: 1.0),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )
        floorEntity.position = [0.5, 0, 0.5]
        return floorEntity
    }

    init() {
        arcballState = ArcBallState(arcballTarget: SIMD3<Float>(0, 0, 0),
                                    radius: 5.0,
                                    inclinationAngle: -Float.pi / 6.0, // around X, slightly "up"
                                    rotationAngle: 0.0, // around Y
                                    inclinationConstraint: -Float.pi / 2 ... 0, // 0 ... 90° 'up'
                                    radiusConstraint: 0.1 ... 50.0)
    }

    var body: some View {
        VStack {
            HStack {
                RealityKitView({ content in
                    // set the motion controls to use scrolling gestures, and allow keyboard support
                    content.arView.motionMode = .arcball(keys: true)
                    content.arView.arcball_state = arcballState

//                    // reflective sphere with default lighting
//                    var sphereMaterial = SimpleMaterial()
//                    sphereMaterial.roughness = .float(0.0)
//                    sphereMaterial.metallic = .float(0.3)
//
//                    let sphereEntity = ModelEntity(mesh: .generateSphere(radius: 0.5),
//                                                   materials: [sphereMaterial])
//
//                    let sphereAnchor = AnchorEntity(world: .zero)
//                    sphereAnchor.addChild(sphereEntity)
//                    content.arView.scene.anchors.append(sphereAnchor)
//
//                    let pointLight = PointLight()
//                    pointLight.light.intensity = 50000
//                    pointLight.light.color = .red
//                    pointLight.position.z = 2.0
//                    sphereAnchor.addChild(pointLight)

                    // print("camera anchor position: \(content.arView.cameraAnchor.position)")
                    let floor = buildFloor(color: .gray) // width: 1, depth:1, at 0,0,0
                    content.add(floor)

                    // Common/conventional 3D axis colors
                    content.add(buildSphere(position: SIMD3<Float>(0, 0, 0), radius: 0.1, color: .black))
                    // RED: x
                    content.add(buildSphere(position: SIMD3<Float>(1, 0, 0), radius: 0.1, color: .red))
                    // GREEN: y
                    content.add(buildSphere(position: SIMD3<Float>(0, 1, 0), radius: 0.1, color: .green))
                    // BLUE: z
                    content.add(buildSphere(position: SIMD3<Float>(0, 0, 1), radius: 0.1, color: .blue))

                    content.add(buildBareQuad(color: .brown))

                    do {
                        try content.add(buildMesh())
                    } catch {
                        print("Failed to add voxel mesh: \(error)")
                    }
                }, update: {
                    // print("update")
                })
                .border(.blue)
                //            RealityView { content in
                //                showTangentCoordinateSystems(modelEntity: me, parent: me.parent!)
                //            }
            }
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            do {
                let loadedLightResource = try EnvironmentResource.load(named: "whitedome")
                Global.arContainer.cameraARView.environment.lighting.resource = loadedLightResource
            } catch {
                print("Unable to load whitedome lighting, using default: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
