//
//  DebugModels.swift
//  RenderExamples
//
//  Created by Joseph Heck on 9/1/24.
//

import Foundation
import RealityGeometries
import RealityKit

public enum DebugModels {
    public static func arrow(material: SimpleMaterial) -> ModelEntity {
        do {
            // vertically oriented, point towards +Y
            // bottom of the shaft at 0,0,0
            let point = try RealityGeometry.generateCone(radius: 0.5, height: 2, sides: 6, splitFaces: false, smoothNormals: true)
            let shaft = try RealityGeometry.generateCylinder(radius: 0.1, height: 8, sides: 6, splitFaces: false, smoothNormals: true)
            let pointEntity = ModelEntity(mesh: point, materials: [material])
            let shaftEntity = ModelEntity(mesh: shaft, materials: [material])
            shaftEntity.position = SIMD3<Float>(0, 4, 0) // move the shaft up 4
            pointEntity.position = SIMD3<Float>(0, 5, 0) // move the center of the cone up 5
            shaftEntity.addChild(pointEntity)
            return shaftEntity
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    public static func sphere(position: simd_float3, radius: Float, material: SimpleMaterial) -> ModelEntity {
        let sphereEntity = ModelEntity(mesh: .generateSphere(radius: radius), materials: [material])
        sphereEntity.position = position
        return sphereEntity
    }
}
