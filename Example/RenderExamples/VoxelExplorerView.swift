import RealityKit
import Spatial
import SwiftUI
import Voxels

struct VoxelExplorerView: View {
    @State private var arcballState: ArcBallState
    @State private var voxelData: VoxelHash<Float> = Voxels.SampleMeshData.SDFBrick()

    let renderer = SurfaceNetRenderer()

    func entityRender(_ voxels: some VoxelAccessible) -> ModelEntity {
        // let voxels = Voxels.SampleMeshData.SDFBrick()
        let generatedMeshBuffer = try! renderer.render(voxelData: voxels, scale: .init(), within: voxels.bounds.expand(2))

        guard let descriptor = generatedMeshBuffer.meshDescriptor() else {
            fatalError("Invalid mesh - no descriptor")
        }
        let mesh = try! MeshResource.generate(from: [descriptor])
        let material = SimpleMaterial(color: .green, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        // entity.name = "SDFBrick"
        return entity
    }

    init() {
        arcballState = ArcBallState(arcballTarget: SIMD3<Float>(0, 0, 0),
                                    radius: 25.0,
                                    inclinationAngle: -Float.pi / 6.0, // around X, slightly "up"
                                    rotationAngle: Float.pi / 8.0, // around Y, slightly to the "right"
                                    inclinationConstraint: -Float.pi / 2 ... 0, // 0 ... 90° 'up'
                                    radiusConstraint: 0.1 ... 150.0)
    }

    var body: some View {
        HStack {
            RealityKitView { content in
                // set the motion controls to use scrolling gestures, and allow keyboard support
                content.arView.motionMode = .arcball(keys: true)
                content.arView.arcball_state = arcballState

                // Debug view helpers
                content.add(DebugModels.gizmo(edge_length: 10))

                content.add(entityRender(voxelData))
            }
            .frame(width: 300, height: 300)
            .border(.blue)
            .padding()
            Spacer()
            Text("Quick Check")
        }
        .padding()
    }
}

#Preview {
    VoxelExplorerView()
}
