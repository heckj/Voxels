import SwiftUI
import Voxels

struct VoxelIndexView: View {
    let vIndex: VoxelIndex

    func coloredAbsString(_ value: Int) -> AttributedString {
        if value >= 0 {
            return AttributedString("\(value)")
        } else {
            var colored = AttributedString("\(abs(value))")
            colored.foregroundColor = .red
            return colored
        }
    }

    func createAttrString() -> AttributedString {
        var assembly = AttributedString("[")
        assembly.inlinePresentationIntent = [.code, .stronglyEmphasized]
        assembly += coloredAbsString(vIndex.x)
        assembly += ","
        assembly += coloredAbsString(vIndex.y)
        assembly += ","
        assembly += coloredAbsString(vIndex.z)
        var finalBit = AttributedString("]")
        finalBit.inlinePresentationIntent = [.code, .stronglyEmphasized]
        assembly += finalBit
        return assembly
    }

    var body: some View {
        HStack {
            Text(createAttrString()).font(.caption)
        }
    }
}

#Preview {
    VoxelIndexView(vIndex: VoxelIndex(-4, 0, 235))
        .padding()
}
