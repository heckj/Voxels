import RealityKit
import RenderExamples
import SnapshotTesting
import Spatial
import SwiftUI
import Voxels
import XCTest

final class SurfaceNetRenderSnapshotTests: XCTestCase {
    #if os(macOS)
        @MainActor
        func testSurfaceNetSphereRender() throws {
            // CAN NOT do a snapshot if the frame is .zero...
            let arView = ARView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))

            addEntity(EntityExample.surfaceNetSphere, to: arView)
            establishCamera(arView, at: Point3D(x: 30, y: 30, z: 50), lookingAt: Point3D(x: 0, y: 0, z: 0))

            // print("Generating Snapshot!!!")

            let imageExpectation = expectation(description: "a 3D image")
            arView.snapshot(saveToHDR: false) { image in
                print("Checking the returned image... \(image.debugDescription)")
                guard let image else {
                    XCTFail("No image generated from ARView snapshot()")
                    return
                }
                assertSnapshot(of: image, as: .image)
                imageExpectation.fulfill()
            }
            wait(for: [imageExpectation], timeout: 10)
        }
    #endif
}
