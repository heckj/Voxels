import SwiftUI
import Voxels

extension VoxelIndex: Identifiable {
    public var id: String {
        description
    }
}

@MainActor
struct VoxelDataEditorView: View {
    let data: ObservableVoxelData
    let bounds: VoxelBounds

    @State private var yLevel: Int

    func numOpaque() -> Int {
        let x = data.wrappedVoxelData.map { renderable in
            renderable.isOpaque()
        }.reduce(0) { partialResult, boolInput in
            boolInput ? partialResult + 1 : partialResult
        }
        return x
    }

    func rowsFromYLevel(y: Int, z: Int) -> [VoxelIndex] {
        (bounds.min.x ... bounds.max.x).map { x in
            VoxelIndex(x, y, z)
        }
    }

    init(data: ObservableVoxelData) {
        self.data = data
        bounds = data.wrappedVoxelData.bounds.expand(2)
        yLevel = data.wrappedVoxelData.bounds.min.y
    }

    var body: some View {
        VStack {
            Text("\(data.wrappedVoxelData.count) stored voxels, \(numOpaque()) opaque")
            Text("Data Bounds: \(data.wrappedVoxelData.bounds)")

            HStack {
                Text("SDF data from level: \(yLevel)").fixedSize()
                VStack {
                    Button(action: {
                        if yLevel + 1 <= bounds.max.y {
                            yLevel = yLevel + 1
                        }
                    }, label: {
                        Text(Image(systemName: "arrowtriangle.up"))
                    })
                    Button(action: {
                        if yLevel - 1 >= bounds.min.y {
                            yLevel = yLevel - 1
                        }
                    }, label: {
                        Text(Image(systemName: "arrowtriangle.down"))
                    })
                }
            }
            ScrollView {
                Grid {
                    ForEach(bounds.min.z ... bounds.max.z, id: \.self) { zValue in
                        // Text("\(zValue)…")
                        GridRow {
                            ForEach(rowsFromYLevel(y: yLevel, z: zValue)) { index in
                                IndividualVoxelEditor(index: index, data: data)
                            }
                        }
                    }
                }
            }
            .padding(4)
            .border(.black)
        }
        .padding()
    }
}

#Preview {
    VoxelDataEditorView(data: ObservableVoxelData(SampleMeshData.SDFBrick())).frame(width: 400, height: 400)
}
