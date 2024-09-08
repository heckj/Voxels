import Foundation

extension VoxelHash where T == Float {
    func dump() {
        for z in (bounds.min.z ... bounds.max.z).reversed() {
            print("Frame (Z): \(z)")
            for y in bounds.min.y ... bounds.max.y {
                var line: String = ""
                for x in bounds.min.x ... bounds.max.x {
                    let index = VoxelIndex(x, y, z)
                    if let value = self[index] {
                        let valueString = value.formatted(.number.precision(.integerAndFractionLength(integerLimits: 1 ... 100, fractionLimits: 0 ... 2)))
                        line += " \(index) : \(valueString) "
                    } else {
                        line += " \(index) :  - "
                    }
                }
                print(line)
            }
            print()
        }
    }
}
