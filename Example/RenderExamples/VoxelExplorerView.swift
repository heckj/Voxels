import RealityKit
import Spatial
import SwiftUI
import Voxels

struct VoxelExplorerView: View {
    let data: ObservableVoxelData

    init(_ data: ObservableVoxelData) {
        self.data = data
    }

    var body: some View {
        HStack {
            ThreeDView(entityToDisplay: data.voxelEntity)
            Spacer()
            VoxelDataEditorView(data: data)
        }
        .padding()
    }
}

#Preview {
    VoxelExplorerView(ObservableVoxelData(SampleMeshData.SDFBrick()))
}
