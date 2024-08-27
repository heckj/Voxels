@testable import RenderExamples

import RealityKit
import SnapshotTesting
import SwiftUI
import XCTest

final class BlockMeshRenderSnapshotTests: XCTestCase {
    #if os(iOS)
        // only works in iOS, **not** macOS
        func testView() {
            let view = ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .black]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Text("Point-Free").bold()
            }
            .frame(width: 200, height: 200)

            assertSnapshot(of: view, as: Snapshotting.image)
        }
    #endif

    // expression ambiguous - so there's something missing in either format to render a snapshot result type - akin to running on macOS
//    @MainActor
//    func testExampleSwiftUIView() async throws {
//        let view = VoxelRenderExample.ContentView()
//        assertSnapshot(of: view, as: .image)
//        XCTAssertNotNil(view)
//    }

//    @MainActor
//    func testExample() async throws {
//        let view = VoxelRenderExample.ContentView()
//        Global.arContainer.cameraARView.snapshot(saveToHDR: false) { image in
//            if let capturedSnapshot = image {
//                assertSnapshot(of: capturedSnapshot, as: .image)
//            } else {
//                XCTFail("No image was generated")
//            }
//        }
//        XCTAssertNotNil(view)
//    }

    #if os(macOS)
        @MainActor
        func testBaselineARViewSphere() throws {
            try XCTSkipIf(ProcessInfo.processInfo.environment["CI"] != nil, "CI Environment, skipping ARView snapshot image test")

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
