import Foundation
import Voxels

struct SDFVoxelData: Identifiable, CustomStringConvertible {
    let id: VoxelIndex
    let rawValue: Float?

    var description: String {
        if let floatValue = rawValue {
            floatValue.formatted(.number.precision(.integerAndFractionLength(integerLimits: 1 ... 100, fractionLimits: 0 ... 2)))
            // return "\(floatValue)"
        } else {
            "-"
        }
    }

    var attrString: AttributedString {
        if let floatValue = rawValue {
            let absFloat = abs(floatValue)
            var attrString = AttributedString(absFloat.formatted(.number.precision(.integerAndFractionLength(integerLimits: 1 ... 100, fractionLimits: 0 ... 2))))
            if floatValue < 0 {
                attrString.foregroundColor = .red
            }
            return attrString
        } else {
            var attrString = AttributedString("-")
            attrString.foregroundColor = .gray
            attrString.inlinePresentationIntent = .code
            return attrString
        }
    }

    init(id: VoxelIndex, rawValue: Float?) {
        self.id = id
        self.rawValue = rawValue
    }

    init(id: VoxelIndex) {
        self.id = id
        rawValue = nil
    }
}
