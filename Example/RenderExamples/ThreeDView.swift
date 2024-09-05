import RealityKit
import Spatial
import SwiftUI
import Voxels

struct ThreeDView: View {
    @State private var arcballState: ArcBallState
    let entityToDisplay: ModelEntity

    var body: some View {
        RealityKitView { content in
            // set the motion controls to use scrolling gestures, and allow keyboard support
            content.arView.motionMode = .arcball(keys: true)
            content.arView.arcball_state = arcballState

            // Debug view helpers
            content.add(DebugModels.gizmo(edge_length: 10))
            content.add(entityToDisplay)
        }
        .border(.blue)
        .padding()
    }

    init(entityToDisplay: ModelEntity) {
        arcballState = ArcBallState(arcballTarget: SIMD3<Float>(0, 0, 0),
                                    radius: 15.0,
                                    inclinationAngle: -Float.pi / 6.0, // around X, slightly "up"
                                    rotationAngle: Float.pi / 8.0, // around Y, slightly to the "right"
                                    inclinationConstraint: -Float.pi / 2 ... 0, // 0 ... 90° 'up'
                                    radiusConstraint: 0.1 ... 150.0)
        self.entityToDisplay = entityToDisplay
    }
}

#Preview {
    ThreeDView(entityToDisplay: ObservableVoxelData(SampleMeshData.SDFBrick()).voxelEntity)
}
