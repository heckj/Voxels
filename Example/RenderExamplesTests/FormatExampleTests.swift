import RealityKit
@testable import RenderExamples
import Spatial
import XCTest

final class FormatExampleTests: XCTestCase {
    func testFormats() throws {
        for floatValue in [0.0, 0.1, 234_523.2, 253.34346, 9_999_999_999.99999] {
            let stringValue = floatValue.formatted(.number.precision(.integerAndFractionLength(integerLimits: 1 ... 100, fractionLimits: 0 ... 2)))
            print(stringValue)

            let altStringValue = floatValue.formatted()
            print(altStringValue)

            let intermediateInt = Int((floatValue * 100.0).rounded())
            let roundedFloat = Float(intermediateInt) * 100
            let alt2StringValue = roundedFloat.formatted(.number.notation(.scientific))
            print(alt2StringValue)
        }
    }
}
