import RealityKit
import SwiftUI
import Voxels

#if os(iOS)
    typealias PlatformColor = UIColor
#elseif os(macOS)
    typealias PlatformColor = NSColor
#endif

enum RendererChoice: String, CaseIterable, Identifiable, CustomStringConvertible {
    case fastSurfaceNet
    case fastSurfaceBlockMesh

    var id: Self { self }

    var description: String {
        rawValue
    }
}

struct ContentView: View {
    @State private var arcballState: ArcBallState
    @State private var selectedRenderer: RendererChoice = .fastSurfaceNet

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

    private func debugEntity() -> ModelEntity {
        let voxels = EntityExample.oneByOne()
        let buffer = VoxelMeshRenderer.fastBlockMesh(voxels, scale: .init())

        let descriptor = buffer.meshDescriptor()
        let mesh = try! MeshResource.generate(from: [descriptor!])
        let material = SimpleMaterial(color: .gray, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.name = "oneByOne"
        return entity
    }

    private func buildBareQuad(color: PlatformColor) -> ModelEntity {
        var buffer = MeshBuffer()
        buffer.addQuadPoints(p1: SIMD3<Float>(0, 1, 0), p2: SIMD3<Float>(0, 0, 0), p3: SIMD3<Float>(1, 1, 0), p4: SIMD3<Float>(1, 0, 0))
        let descriptor = buffer.meshDescriptor()
        let mesh = try! MeshResource.generate(from: [descriptor!])
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
                                    radius: 50.0,
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

//                    content.add(debugEntity())

                    switch selectedRenderer {
                    case .fastSurfaceNet:
                        if let other = Global.arContainer.cameraARView.scene.findEntity(named: "fastSurfaceBlock") {
                            other.parent?.removeChild(other)
                        }
                        content.add(EntityExample.surfaceNetSphere)
                    case .fastSurfaceBlockMesh:
                        if let other = Global.arContainer.cameraARView.scene.findEntity(named: "surfaceNet") {
                            other.parent?.removeChild(other)
                        }
                        content.add(EntityExample.fastSurfaceBlockMeshSphere)
                    }

                }, update: {
                    // print("update")
                })
                .border(.blue)
            }
            Text("Hello, world!")
            Picker("Renderer Choice", selection: $selectedRenderer) {
                ForEach(RendererChoice.allCases) { option in
                    Text(option.rawValue)
                }
            }
            // .pickerStyle(.wheel)
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
