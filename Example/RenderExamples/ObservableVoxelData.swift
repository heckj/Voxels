import SwiftUI
import Voxels

@Observable
@MainActor
class ObservableVoxelData {
    public var wrappedVoxelData: VoxelHash<Float>

    init(_ data: VoxelHash<Float>) {
        wrappedVoxelData = data
    }

    func binding(_ index: VoxelIndex) -> Binding<String> {
        let voxelSDFValueBinding: Binding<String> = Binding {
            if let value = self.wrappedVoxelData[index] {
                "\(value)"
            } else {
                ""
            }
        } set: { newStringValue in
            if newStringValue.isEmpty {
                self.wrappedVoxelData[index] = nil
            } else {
                if let newFloatValue = Float(newStringValue) {
                    self.wrappedVoxelData[index] = newFloatValue
                }
            }
        }
        return voxelSDFValueBinding
    }
}
