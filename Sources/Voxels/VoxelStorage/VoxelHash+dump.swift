import Foundation

extension VoxelHash where T == Float {
    func dump() {
        for y in (bounds.min.y ... bounds.max.y).reversed() {
            print("Frame (Y): \(y)")
            for z in bounds.min.z ... bounds.max.z {
                var line = ""
                for x in bounds.min.x ... bounds.max.x {
                    let index = VoxelIndex(x, y, z)
                    if let value = self[index] {
                        #if os(Linux)
                            let valueString = "\(value)"
                        // .formatted doesn't appear to be available on Linux through Foundation, but
                        // I might be holding it wrong...
                        #else
                            let valueString = value.formatted(.number.precision(.integerAndFractionLength(integerLimits: 1 ... 100, fractionLimits: 0 ... 2)))
                        #endif
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
