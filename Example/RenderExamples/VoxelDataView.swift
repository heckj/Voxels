import SwiftUI
import Voxels

struct IndexedDistance: Identifiable {
    let id: VoxelIndex
    let value: String
}

struct VoxelDataView: View {
    let voxelData: any VoxelAccessible
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

    func rowsFromYLevel(y: Int, z: Int) -> [IndexedDistance] {
        var row: [IndexedDistance] = []
        for x in bounds.min.x ... bounds.max.x {
            let index = VoxelIndex(x, y, z)
            if let singleVoxeldata = voxelData[index] {
                row.append(IndexedDistance(id: index, value: "\(singleVoxeldata.distanceAboveSurface())"))
            } else {
                row.append(IndexedDistance(id: index, value: "?"))
            }
        }
        return row
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
                                Text("\(indexedCellData.id)").font(.caption)
                                Text(indexedCellData.value)
                            }
                        }
                    }
                }
            }
            .padding()
            .border(.black)
        }
        .padding()
        .onAppear(perform: {
            yLevel = bounds.min.y
        })
    }
}

#Preview {
    VoxelDataView(voxelData: SampleMeshData.manhattanNeighbor1(), bounds: SampleMeshData.manhattanNeighbor1().bounds.expand(2)).frame(width: 400, height: 400)
}
