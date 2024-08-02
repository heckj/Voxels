import CameraControlARView
import RealityKit
import SwiftUI
import Voxels

struct ContentView: View {
    private func sdf_to_buffer(sdf: SDF<Float>) -> SurfaceNetsBuffer {
        let sampleShape = VoxelArray<UInt32>(size: 34, value: 0)
        // type SampleShape = ConstShape3u32<34, 34, 34>;

        var samples: [Float] = Array(repeating: 0.0, count: sampleShape.size)

        for i in 0 ..< (sampleShape.size) {
            let position: SIMD3<Float> = into_domain(array_dim: 32, sampleShape.delinearize(UInt(i)))
            samples[i] = sdf.valueAt(position)
        }

        return surface_nets(
            sdf: samples,
            shape: sampleShape,
            min: SIMD3<UInt32>(0, 0, 0),
            max: SIMD3<UInt32>(33, 33, 33)
        )
    }

    private func into_domain(array_dim: UInt, _ xyz: SIMD3<UInt>) -> SIMD3<Float> {
        // samples over a quadrant - starts at -1 and goes up to (2/edgeSize * (edgeSize-1)) - 1
        (2.0 / Float(array_dim)) * SIMD3<Float>(Float(xyz.x), Float(xyz.y), Float(xyz.z)) - 1.0
    }

    private func sphere(radius: Float, p: Vector) -> Float {
        p.length - radius
    }

    private func buildMesh() -> ModelEntity {
        let sphereSDF = SDF<Float>() { _, _, _ in
            sphere(radius: 0.5, p: Vector(0, 0, 0))
        }
        let buffer = sdf_to_buffer(sdf: sphereSDF)
        let descriptor = buffer.meshDescriptor()
        let mesh = try! MeshResource.generate(from: [descriptor])
        let material = SimpleMaterial(color: .green, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }

    private func showTangentCoordinateSystems(modelEntity: ModelEntity, parent: Entity) {
        let axisLength: Float = 0.02

        for model in modelEntity.model!.mesh.contents.models {
            for part in model.parts {
                var positions: [simd_float3] = []

                for position in part.positions {
                    parent.addChild(buildSphere(position: position, radius: 0.005, color: .black))
                    positions.append(position)
                }

                for (i, tangent) in part.tangents!.enumerated() {
                    parent.addChild(buildSphere(position: positions[i] + (axisLength * tangent), radius: 0.0025, color: .red))
                }

                for (i, bitangent) in part.bitangents!.enumerated() {
                    parent.addChild(buildSphere(position: positions[i] + (axisLength * bitangent), radius: 0.0025, color: .green))
                }

                for (i, normal) in part.normals!.enumerated() {
                    parent.addChild(buildSphere(position: positions[i] + (axisLength * normal), radius: 0.0025, color: .blue))
                }
            }
        }
    }

    private func buildSphere(position: simd_float3, radius: Float, color: NSColor) -> ModelEntity {
        let sphereEntity = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])
        sphereEntity.position = position
        return sphereEntity
    }

    private func buildFloor(color: NSColor) -> ModelEntity {
        let floorEntity = ModelEntity(
            mesh: .generatePlane(width: 1.0, depth: 1.0),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )
        floorEntity.position = [0.5, 0, 0.5]
        return floorEntity
    }

    var body: some View {
        VStack {
            RealityKitView({ content in
                // camera is positioned (at the start) at 0,0,2, looking in -Z direction
                // so, loosely ~2m back from 0,0,0
                // - this is derived from radius: 2, inclination: 0, rotation: 0

                // look at point
                content.arView.arcballTarget = SIMD3<Float>(0, 0, 0)

                print("initial inclination: \(content.arView.inclinationAngle)") // 0.0
                print("initial rotation: \(content.arView.rotationAngle)") // 0.0
                print("initial radius: \(content.arView.radius)") // 2.0
                print("camera anchor position: \(content.arView.cameraAnchor.position)")
                let floor = buildFloor(color: .blue) // width: 1, depth:1, at 0,0,0
                content.add(floor)

                // lower left
                content.add(buildSphere(position: SIMD3<Float>(0, 0, 0), radius: 0.05, color: .red))
                // lower right
                content.add(buildSphere(position: SIMD3<Float>(1, 0, 0), radius: 0.05, color: .red))

                // upper right
                content.add(buildSphere(position: SIMD3<Float>(0, 1, 0), radius: 0.05, color: .red))
                // upper left
                content.add(buildSphere(position: SIMD3<Float>(1, 1, 0), radius: 0.05, color: .red))
                content.add(buildMesh())
            }, update: {
                // print("update")
            })
            .border(.blue)
//            RealityView { content in
//                showTangentCoordinateSystems(modelEntity: me, parent: me.parent!)
//            }
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
