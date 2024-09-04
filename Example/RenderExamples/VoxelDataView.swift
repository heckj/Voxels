import SwiftUI
import Voxels

struct VoxelDataView: View {
    let voxelData: any VoxelAccessible

    func numSurface() -> Int {
        let x = voxelData.map { renderable in
            renderable.isOpaque()
        }.reduce(0) { partialResult, boolInput in
            boolInput ? partialResult + 1 : partialResult
        }
        return x
    }

    var body: some View {
        VStack {
            Text("\(voxelData.count) stored voxels, \(numSurface()) surface")
            Text("Bounds: \(voxelData.bounds)")
        }
        .padding()
    }
}

#Preview {
    VoxelDataView(voxelData: SampleMeshData.manhattanNeighbor1())
}
