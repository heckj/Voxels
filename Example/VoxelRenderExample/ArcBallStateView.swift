import SwiftUI
import CameraControlARView

struct ArcBallStateView: View {
    let state: ArcBallState
    var body: some View {
        VStack {
            Text("inclination: \(state.inclinationAngle) (rad)")
            Text("rotation: \(state.rotationAngle) (rad)")
            Text("radius: \(state.radius) (m)")
            Text("target: \(state.arcballTarget)")
        }
    }
}

#Preview {
    ArcBallStateView(state: ArcBallState())
}
