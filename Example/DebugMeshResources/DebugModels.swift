//
//  DebugModels.swift
//  RenderExamples
//
//  Created by Joseph Heck on 9/1/24.
//

import Foundation
import RealityGeometries
import RealityKit
import Spatial

public enum DebugModels {
    public static func arrow(material: SimpleMaterial, length: Float = 10.0) -> ModelEntity {
        do {
            // vertically oriented, point towards +Y
            // bottom of the shaft at 0,0,0
            let point = try RealityGeometry.generateCone(radius: length / 20, height: length * 0.2, sides: 6, splitFaces: false, smoothNormals: true)
            let shaft = try RealityGeometry.generateCylinder(radius: length / 100, height: length * 0.8, sides: 6, splitFaces: false, smoothNormals: true)
            let pointEntity = ModelEntity(mesh: point, materials: [material])
            let shaftEntity = ModelEntity(mesh: shaft, materials: [material])
            // move the shaft up 4 (for a length 10)
            shaftEntity.position = SIMD3<Float>(0, length * 0.4, 0)
            // move the center of the cone up 5 (for a length 10)
            pointEntity.position = SIMD3<Float>(0, length * 0.5, 0)
            shaftEntity.addChild(pointEntity)
            return shaftEntity
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    public static func gizmo(position: simd_float3 = simd_float3(0, 0, 0), edge_length: Float = 10.0) -> ModelEntity {
        let sphereCore = Self.sphere(position: position, radius: edge_length / 50.0, material: SimpleMaterial(color: .black, isMetallic: false))

        let yArrow: ModelEntity = DebugModels.arrow(material: SimpleMaterial(color: .green, isMetallic: false),
                                                    length: edge_length)
        sphereCore.addChild(yArrow)

        let xArrow: ModelEntity = DebugModels.arrow(material: SimpleMaterial(color: .red, isMetallic: false),
                                                    length: edge_length)
        xArrow.transform.rotation = simd_quatf(
            Rotation3D(angle: Angle2D(degrees: -90), axis: RotationAxis3D.z)
        )
        xArrow.position = SIMD3<Float>(edge_length * 0.4, 0, 0)
        sphereCore.addChild(xArrow)

        let zArrow: ModelEntity = DebugModels.arrow(material: SimpleMaterial(color: .blue, isMetallic: false),
                                                    length: edge_length)
        zArrow.transform.rotation = simd_quatf(
            Rotation3D(angle: Angle2D(degrees: 90), axis: RotationAxis3D.x)
        )
        zArrow.position = SIMD3<Float>(0, 0, edge_length * 0.4)
        sphereCore.addChild(zArrow)

        return sphereCore
    }

    public static func sphere(position: simd_float3, radius: Float, material: SimpleMaterial) -> ModelEntity {
        let sphereEntity = ModelEntity(mesh: .generateSphere(radius: radius), materials: [material])
        sphereEntity.position = position
        return sphereEntity
    }
}
