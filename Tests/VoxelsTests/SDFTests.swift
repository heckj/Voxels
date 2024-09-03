import Voxels
import XCTest

final class SDFTests: XCTestCase {
    func testSphereSDFMeasures() throws {
        let sphereSDF = SDF.sphere()

        XCTAssertEqual(sphereSDF.valueAt(x: 0, y: 0, z: 0), -0.5)
        XCTAssertEqual(sphereSDF.valueAt(x: 0.25, y: 0, z: 0), -0.25)
        XCTAssertEqual(sphereSDF.valueAt(x: 0.5, y: 0, z: 0), 0)
        XCTAssertEqual(sphereSDF.valueAt(x: 1, y: 0, z: 0), 0.5)
    }
}
