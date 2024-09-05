import RealityKit
import Spatial
import SwiftUI
import Voxels

struct VoxelExplorerView: View {
    @State private var arcballState: ArcBallState
    let data: ObservableVoxelData

    let renderer = SurfaceNetRenderer()

    func entityRender(_ voxels: some VoxelAccessible) -> ModelEntity {
        // Get the Metal Device, then the library from the device
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = device.makeDefaultLibrary()
        else {
            fatalError("Error creating default metal device.")
        }

//        let geometryModifier = CustomMaterial.GeometryModifier(named: "wireframeMaterialGeometryModifier", in: library)

        // Load a surface shader function named mySurfaceShader.
//        let surfaceShader = CustomMaterial.SurfaceShader(named: "wireframeMaterialSurfaceShader", in: library)
        do {
            #if os(macOS)
                let baseMaterial = SimpleMaterial(color: .lightGray, isMetallic: false)
            #else
                let baseMaterial = SimpleMaterial(color: .lightGray, isMetallic: false)
            #endif
//            let material = try CustomMaterial(surfaceShader: surfaceShader, geometryModifier: geometryModifier, lightingModel: .clearcoat)
//            let material = try CustomMaterial(from: baseMaterial, surfaceShader: surfaceShader)
//            let material = try CustomMaterial(surfaceShader: surfaceShader, lightingModel: .unlit)

            let generatedMeshBuffer = try! renderer.render(voxelData: voxels, scale: .init(), within: voxels.bounds.expand(2))

            guard let descriptor = generatedMeshBuffer.meshDescriptor() else {
                fatalError("Invalid mesh - no descriptor")
            }
            let mesh = try! MeshResource.generate(from: [descriptor])
            let entity = ModelEntity(mesh: mesh, materials: [baseMaterial])
            // entity.name = "SDFBrick"
            return entity

        } catch {
            fatalError(error.localizedDescription)
        }
    }

    init(_ data: ObservableVoxelData) {
        arcballState = ArcBallState(arcballTarget: SIMD3<Float>(0, 0, 0),
                                    radius: 15.0,
                                    inclinationAngle: -Float.pi / 6.0, // around X, slightly "up"
                                    rotationAngle: Float.pi / 8.0, // around Y, slightly to the "right"
                                    inclinationConstraint: -Float.pi / 2 ... 0, // 0 ... 90° 'up'
                                    radiusConstraint: 0.1 ... 150.0)
        self.data = data
    }

    var body: some View {
        HStack {
            RealityKitView { content in
                // set the motion controls to use scrolling gestures, and allow keyboard support
                content.arView.motionMode = .arcball(keys: true)
                content.arView.arcball_state = arcballState

                // Debug view helpers
                content.add(DebugModels.gizmo(edge_length: 10))

                content.add(entityRender(data.wrappedVoxelData))
            }
            .frame(width: 400, height: 400)
            .border(.blue)
            .padding()
            Spacer()
            VoxelDataEditorView(data: data)
        }
        .padding()
    }
}

#Preview {
    VoxelExplorerView(ObservableVoxelData(SampleMeshData.SDFBrick()))
}
