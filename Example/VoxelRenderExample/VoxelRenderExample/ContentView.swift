import CameraControlARView
import RealityKit
import SwiftUI

@available(macOS 15.0, *)
struct ContentView: View {
    // https://codingxr.com/articles/procedural-mesh-in-realitykit/
    private func buildMesh(numCells: simd_int2, cellSize: Float) -> ModelEntity {
        var positions: [simd_float3] = []
        var textureCoordinates: [simd_float2] = []
        var triangleIndices: [UInt32] = []

        let size: simd_float2 = [Float(numCells.x) * cellSize, Float(numCells.y) * cellSize]
        // Offset is used to make the origin in the center
        let offset: simd_float2 = [size.x / 2, size.y / 2]
        var i: UInt32 = 0

        for row in 0 ..< numCells.y {
            for col in 0 ..< numCells.x {
                let x = (Float(col) * cellSize) - offset.x
                let z = (Float(row) * cellSize) - offset.y

                positions.append([x, 0, z])
                positions.append([x + cellSize, 0, z])
                positions.append([x, 0, z + cellSize])
                positions.append([x + cellSize, 0, z + cellSize])

                textureCoordinates.append([0.0, 0.0])
                textureCoordinates.append([1.0, 0.0])
                textureCoordinates.append([0.0, 1.0])
                textureCoordinates.append([1.0, 1.0])

                // Triangle 1
                triangleIndices.append(i)
                triangleIndices.append(i + 2)
                triangleIndices.append(i + 1)

                // Triangle 2
                triangleIndices.append(i + 1)
                triangleIndices.append(i + 2)
                triangleIndices.append(i + 3)

                i += 4
            }
        }

        var descriptor = MeshDescriptor(name: "proceduralMesh")
        descriptor.positions = MeshBuffer(positions)
        descriptor.primitives = .triangles(triangleIndices)
        descriptor.textureCoordinates = MeshBuffer(textureCoordinates)

        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .white, texture: .init(try! .load(named: "base_color")))
        material.normal = .init(texture: .init(try! .load(named: "normal")))
        let mesh = try! MeshResource.generate(from: [descriptor])

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

    private func buildSphere(position: simd_float3, radius: Float, color: UIColor) -> ModelEntity {
        let sphereEntity = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])
        sphereEntity.position = position
        return sphereEntity
    }

    private func buildFloor(color: UIColor) -> ModelEntity {
        let floorEntity = ModelEntity(
            mesh: .generatePlane(width: 2.0, depth: 2.0),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )
        floorEntity.position = [0, -1, -2]
        return floorEntity
    }

    var body: some View {
        VStack {
            RealityKitView({ content in
                let floor = buildFloor(color: .blue)
                content.add(floor)
                let me = buildSphere(position: SIMD3<Float>(0, 0, -2), radius: 1.0, color: .red)
                content.add(me)
            }, update: {
                // print("update")
            })
            .border(.blue)
//            RealityView { content in
            ////                showTangentCoordinateSystems(modelEntity: me, parent: me.parent!)
//            }
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
