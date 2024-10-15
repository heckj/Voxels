//
//  VoxelEntity.swift
//  RenderExamples
//
//  Created by Joseph Heck on 10/15/24.
//

import RealityKit
import Voxels

enum VoxelEntity {
    public static func voxelEntity(_ idx: VoxelIndex, scale: VoxelScale<Float>, color: PlatformColor) -> ModelEntity {
        var pbrColor = PhysicallyBasedMaterial()
        pbrColor.baseColor = PhysicallyBasedMaterial.BaseColor(tint: color)
        pbrColor.metallic = 0.0

        guard let meshDescriptor = BlockMeshRenderer.renderFramedVoxel(idx: idx, scale: scale, inset: scale.cubeSize / 10).meshDescriptor() else {
            fatalError("Invalid mesh descriptor from rendering")
        }
        let meshResource = try! MeshResource.generate(from: [meshDescriptor])
        let baseEntity = ModelEntity(mesh: meshResource, materials: [pbrColor])
        return baseEntity
    }
}
