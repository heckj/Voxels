import RealityKit
import Spatial
import SwiftUI
import Voxels

struct VoxelExplorerView: View {
    let data: ObservableVoxelData
    @State var visibleBlockMesh = false

    init(_ data: ObservableVoxelData) {
        self.data = data
    }

    var body: some View {
        HStack {
            VStack {
                Toggle(isOn: $visibleBlockMesh) {
                    Text("overlay the 'opaque' voxels")
                }
                .onChange(of: visibleBlockMesh) { _, newValue in
                    data.enableBlockMesh = newValue
                }

                ThreeDView(entityToDisplay: data.voxelEntity)
            }
            Spacer()
            VoxelDataEditorView(data: data)
        }
        .padding()
    }
}

#Preview {
    VoxelExplorerView(ObservableVoxelData(SampleMeshData.HeightmapSurface()))
}
