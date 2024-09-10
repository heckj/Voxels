import RealityKit
import RenderExamples
import SnapshotTesting
import Spatial
import SwiftUI
import Voxels
import XCTest

final class MarchingCubesRenderSnapshotTests: XCTestCase {
    #if os(macOS)
        @MainActor
        func testMarchingCubesSphereRender() throws {
            // CAN NOT do a snapshot if the frame is .zero...
            let arView = ARView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))

            addEntity(marchingCubesEntity(EntityExample.sampledSDFSphere()), to: arView)
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

        @MainActor
        func testBlockMeshSingleVoxel() throws {
            // CAN NOT do a snapshot if the frame is .zero...
            let arView = ARView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))

            let entity = marchingCubesEntity(EntityExample.oneByOne())
            addEntity(entity, to: arView)
            establishCamera(arView, at: Point3D(x: 6, y: 6, z: 10), lookingAt: Point3D(x: 0, y: 0, z: 0))

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

        @MainActor
        func testBlockMeshThreeByThreeVoxel() throws {
            // CAN NOT do a snapshot if the frame is .zero...
            let arView = ARView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))

            let entity = marchingCubesEntity(EntityExample.threeByThree())
            addEntity(entity, to: arView)
            establishCamera(arView, at: Point3D(x: 6, y: 6, z: 10), lookingAt: Point3D(x: 0, y: 0, z: 0))

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

        @MainActor
        func testBlockMeshManhattanNeighborOneVoxel() throws {
            // CAN NOT do a snapshot if the frame is .zero...
            let arView = ARView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))

            let entity = marchingCubesEntity(SampleMeshData.manhattanNeighbor1())
            addEntity(entity, to: arView)
            establishCamera(arView, at: Point3D(x: 6, y: 6, z: 10), lookingAt: Point3D(x: 0, y: 0, z: 0))

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

        @MainActor
        func testBlockMeshFlatYBlock() throws {
            // CAN NOT do a snapshot if the frame is .zero...
            let arView = ARView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))

            let voxels = SampleMeshData.flatYBlock()
            XCTAssertEqual(voxels.count, 200)
            let entity = marchingCubesEntity(voxels)
            addEntity(entity, to: arView)
            establishCamera(arView, at: Point3D(x: 15, y: 6, z: 7), lookingAt: Point3D(x: 5, y: 0, z: 5))

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
