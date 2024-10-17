////  Created by Max Cobb on 12/06/2021.
////  Used under MIT license, acquired from
////  https://github.com/maxxfrazer/RealityGeometries/blob/main/Sources/RealityGeometries/CompleteVertex.swift
////
// #if canImport(RealityKit)
//    import RealityKit
//
//    extension [CompleteVertex] {
//        func generateMeshDescriptor(
//            with indices: [UInt32], materials: [UInt32] = []
//        ) -> MeshDescriptor {
//            var meshDescriptor = MeshDescriptor()
//            var positions: [SIMD3<Float>] = []
//            var normals: [SIMD3<Float>] = []
//            var uvs: [SIMD2<Float>] = []
//            for vx in self {
//                positions.append(vx.position)
//                normals.append(vx.normal)
//                uvs.append(vx.uv)
//            }
//            meshDescriptor.positions = MeshBuffers.Positions(positions)
//            meshDescriptor.normals = MeshBuffers.Normals(normals)
//            meshDescriptor.textureCoordinates = MeshBuffers.TextureCoordinates(uvs)
//            meshDescriptor.primitives = .triangles(indices)
//            if !materials.isEmpty {
//                meshDescriptor.materials = MeshDescriptor.Materials.perFace(materials)
//            }
//            return meshDescriptor
//        }
//    }
// #endif
