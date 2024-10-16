import RealityKit
import Spatial
@testable import VoxelRenderExample
import XCTest

final class CameraControlARViewTests: XCTestCase {
    func testInitialArcBallStateTransform() throws {
        let initial = ArcBallState()

        let result: Transform = initial.cameraTransform()

        XCTAssertEqual(result.translation.x, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.translation.y, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.translation.z, 2.0, accuracy: 0.01)

        XCTAssertEqual(result.eulerAngles.x, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.eulerAngles.y, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.eulerAngles.z, 0.0, accuracy: 0.01)

        let heading = headingVector(result)
        XCTAssertEqual(heading.x, 0, accuracy: 0.01)
        XCTAssertEqual(heading.y, 0, accuracy: 0.01)
        XCTAssertEqual(heading.z, -1.0, accuracy: 0.01)
    }

    func testRotatedArcBallStateTransform() throws {
        let initial = ArcBallState(rotationAngle: Float.pi / 2)

        let result: Transform = initial.cameraTransform()

        XCTAssertEqual(result.translation.x, 2.0, accuracy: 0.01)
        XCTAssertEqual(result.translation.y, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.translation.z, 0.0, accuracy: 0.01)

        XCTAssertEqual(result.eulerAngles.x, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.eulerAngles.y, Float.pi / 2.0, accuracy: 0.01)
        XCTAssertEqual(result.eulerAngles.z, 0, accuracy: 0.01)

        let heading = headingVector(result)
        XCTAssertEqual(heading.x, -1.0, accuracy: 0.01)
        XCTAssertEqual(heading.y, 0, accuracy: 0.01)
        XCTAssertEqual(heading.z, 0, accuracy: 0.01)
    }
}
