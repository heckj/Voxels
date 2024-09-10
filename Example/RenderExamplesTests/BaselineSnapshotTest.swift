import RealityKit
import RenderExamples
import SnapshotTesting
import Spatial
import SwiftUI
import Voxels
import XCTest

final class BaselineSnapshotTests: XCTestCase {
    #if os(macOS)
        @MainActor
        func testBaselineARViewSphere() throws {
            // CAN NOT do a snapshot if the frame is .zero...
            let arView = ARView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))

            // set up the scene
            var sphereMaterial = SimpleMaterial()
            sphereMaterial.roughness = .float(0.0)
            sphereMaterial.metallic = .float(0.3)

            let sphereEntity = ModelEntity(mesh: .generateSphere(radius: 0.5),
                                           materials: [sphereMaterial])

            let sphereAnchor = AnchorEntity(world: .zero)
            sphereAnchor.addChild(sphereEntity)
            arView.scene.anchors.append(sphereAnchor)

            let pointLight = PointLight()
            pointLight.light.intensity = 50000
            pointLight.light.color = .red
            pointLight.position.z = 2.0
            sphereAnchor.addChild(pointLight)

            print("Generating Snapshot!!!")
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
