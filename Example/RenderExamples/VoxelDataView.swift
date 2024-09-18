import SwiftUI
import Voxels

struct VoxelDataView<VOXEL: VoxelBlockRenderable & VoxelSurfaceRenderable>: View {
    let voxelData: any VoxelAccessible<VOXEL>
    let bounds: VoxelBounds

    @State private var yLevel: Int = 0

    func numSurface() -> Int {
        let x = voxelData.map { renderable in
            renderable.isOpaque()
        }.reduce(0) { partialResult, boolInput in
            boolInput ? partialResult + 1 : partialResult
        }
        return x
    }

    func rowsFromYLevel(y: Int, z: Int) -> [SDFVoxelData] {
        var row: [SDFVoxelData] = []
        for x in bounds.min.x ... bounds.max.x {
            let index = VoxelIndex(x, y, z)
            if let singleVoxeldata = voxelData[index] {
                row.append(SDFVoxelData(id: index, rawValue: singleVoxeldata.distanceAboveSurface()))
            } else {
                row.append(SDFVoxelData(id: index))
            }
        }
        return row
    }

    init(voxelData: any VoxelAccessible<VOXEL>) {
        self.voxelData = voxelData
        bounds = voxelData.bounds.expand(2)
        yLevel = bounds.min.y
    }

    var body: some View {
        VStack {
            Text("\(voxelData.count) stored voxels, \(numSurface()) surface")
            Text("Data Bounds: \(voxelData.bounds)")

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
            Grid {
                ForEach(bounds.min.z ... bounds.max.z, id: \.self) { zValue in
                    // Text("\(zValue)…")
                    GridRow {
                        ForEach(rowsFromYLevel(y: yLevel, z: zValue)) { indexedCellData in
                            VStack {
                                VoxelIndexView(vIndex: indexedCellData.id)
                                Text(indexedCellData.attrString)
                            }
                        }
                    }
                }
            }
            .padding()
            .border(.black)
        }
        .padding()
    }
}

#Preview {
    VoxelDataView<Float>(voxelData: SampleMeshData.manhattanNeighbor1())
        .frame(width: 400, height: 400)
}
