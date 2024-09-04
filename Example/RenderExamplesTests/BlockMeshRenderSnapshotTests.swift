import RealityKit
import RenderExamples
import SnapshotTesting
import Spatial
import SwiftUI
import Voxels
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

        func establishCamera(_ arView: ARView, at camera_position: Point3D, lookingAt: Point3D) {
            // Establish an explicit camera for the scene
            let cameraEntity = PerspectiveCamera()
            cameraEntity.camera.fieldOfViewInDegrees = 60
            let cameraAnchor = AnchorEntity(world: .zero)
            cameraAnchor.addChild(cameraEntity)
            arView.scene.addAnchor(cameraAnchor)
            // position the camera
            let lookRotation = Rotation3D(position: lookingAt,
                                          target: camera_position,
                                          up: Vector3D(x: 0, y: 1, z: 0))
            cameraAnchor.transform = Transform(scale: .one, rotation: simd_quatf(lookRotation), translation: SIMD3<Float>(camera_position))
        }

        func addEntity(_ entity: ModelEntity, to arView: ARView) {
            let originAnchor = AnchorEntity(world: .zero)
            originAnchor.addChild(entity)
            arView.scene.anchors.append(originAnchor)
        }

        func blockMeshEntity(_ samples: some VoxelAccessible) -> ModelEntity {
            let buffer = VoxelMeshRenderer.fastBlockMesh(samples, scale: .init())
            let descriptor = buffer.meshDescriptor()
            let mesh = try! MeshResource.generate(from: [descriptor!])
            let material = SimpleMaterial(color: .green, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            return entity
        }

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

        @MainActor
        func testBlockMeshSphereRender() throws {
            // CAN NOT do a snapshot if the frame is .zero...
            let arView = ARView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))

            addEntity(EntityExample.fastSurfaceBlockMeshSphere, to: arView)
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

            let entity = blockMeshEntity(EntityExample.oneByOne())
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

            let entity = blockMeshEntity(EntityExample.threeByThree())
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

            let entity = blockMeshEntity(SampleMeshData.manhattanNeighbor1())
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
            XCTAssertEqual(voxels.count, 100)
            let entity = blockMeshEntity(voxels)
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
