import RealityKit
import Spatial
import SwiftUI

// #if os(iOS)
//    typealias PlatformColor = UIColor
// #elseif os(macOS)
//    typealias PlatformColor = NSColor
// #endif

struct QuickCheckView: View {
    @State private var arcballState: ArcBallState

    init() {
        arcballState = ArcBallState(arcballTarget: SIMD3<Float>(0, 0, 0),
                                    radius: 15.0,
                                    inclinationAngle: -Float.pi / 6.0, // around X, slightly "up"
                                    rotationAngle: Float.pi / 8.0, // around Y, slightly to the "right"
                                    inclinationConstraint: -Float.pi / 2 ... 0, // 0 ... 90° 'up'
                                    radiusConstraint: 0.1 ... 150.0)
    }

    var body: some View {
        VStack {
            HStack {
                RealityKitView { content in
                    // set the motion controls to use scrolling gestures, and allow keyboard support
                    content.arView.motionMode = .arcball(keys: true)
                    content.arView.arcball_state = arcballState

                    // Common/conventional 3D axis colors
                    content.add(DebugModels.sphere(position: SIMD3<Float>(0, 0, 0),
                                                   radius: 0.2,
                                                   material: SimpleMaterial(color: .black, isMetallic: false)))

                    // Debug view helpers
                    // content.add(DebugModels.gizmo(edge_length: 10))
                    // content.add(DebugModels.gridWall(edge_length: 100))

                     content.add(EntityExample.surfaceNetBrick)
                }
                .border(.blue)
            }
            Text("Quick Check")
        }
        .padding()
    }
}

#Preview {
    QuickCheckView()
}
