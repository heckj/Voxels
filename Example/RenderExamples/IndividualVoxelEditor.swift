import SwiftUI
import Voxels

struct IndividualVoxelEditor: View {
    let index: VoxelIndex
    let data: ObservableVoxelData

    var body: some View {
        VStack {
            VoxelIndexView(vIndex: index)
            Spacer()
            TextField("value", text: data.binding(index))
                .disableAutocorrection(true)
        }
        .padding(2)
        .border(.black)
        .frame(width: 45, height: 45)
    }
}

#Preview {
    IndividualVoxelEditor(index: VoxelIndex(2, 2, 2), data: ObservableVoxelData(SampleMeshData.SDFBrick()))
        .padding()
}
