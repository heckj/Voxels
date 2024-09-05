import RealityKit
import SwiftUI
import Voxels

@Observable
@MainActor
class ObservableVoxelData {
    public var wrappedVoxelData: VoxelHash<Float>
    let renderer: SurfaceNetRenderer
    let voxelEntity: ModelEntity
    #if os(macOS)
        let baseMaterial = SimpleMaterial(color: .lightGray, isMetallic: false)
    #else
        let baseMaterial = SimpleMaterial(color: .lightGray, isMetallic: false)
    #endif

    let clock = ContinuousClock()

    init(_ data: VoxelHash<Float>) {
        renderer = SurfaceNetRenderer()
        wrappedVoxelData = data
        let generatedMeshBuffer = try! renderer.render(voxelData: data,
                                                       scale: .init(),
                                                       within: data.bounds.expand(2))

        guard let descriptor = generatedMeshBuffer.meshDescriptor() else {
            fatalError("Invalid mesh - no descriptor")
        }
        let mesh = try! MeshResource.generate(from: [descriptor])
        voxelEntity = ModelEntity(mesh: mesh, materials: [baseMaterial])
        voxelEntity.name = "VoxelData"
    }

    func binding(_ index: VoxelIndex) -> Binding<String> {
        let voxelSDFValueBinding: Binding<String> = Binding {
            if let value = self.wrappedVoxelData[index] {
                "\(value)"
            } else {
                ""
            }
        } set: { newStringValue in
            if newStringValue.isEmpty {
                self.wrappedVoxelData[index] = nil
                self.redoRender()
            } else {
                if let newFloatValue = Float(newStringValue) {
                    self.wrappedVoxelData[index] = newFloatValue
                    self.redoRender()
                }
            }
        }
        return voxelSDFValueBinding
    }

    func redoRender() {
        let startTime = clock.now
        let generatedMeshBuffer = try! renderer.render(voxelData: wrappedVoxelData,
                                                       scale: .init(),
                                                       within: wrappedVoxelData.bounds.expand(2))
        let timeToRender = clock.now - startTime

        print("Render Duration: \(timeToRender.formatted(.units(allowed: [.milliseconds, .microseconds], width: .abbreviated))) (\(timeToRender.description))")
        guard let descriptor = generatedMeshBuffer.meshDescriptor() else {
            return
        }
        let mesh = try! MeshResource.generate(from: [descriptor])
        voxelEntity.model?.mesh = mesh
    }

//    func renderEntity(_ voxels: some VoxelAccessible) -> ModelEntity {
//        // Get the Metal Device, then the library from the device
//        guard let device = MTLCreateSystemDefaultDevice(),
//              let library = device.makeDefaultLibrary()
//        else {
//            fatalError("Error creating default metal device.")
//        }
//
//        let geometryModifier = CustomMaterial.GeometryModifier(named: "wireframeMaterialGeometryModifier", in: library)
//
//         Load a surface shader function named mySurfaceShader.
//        let surfaceShader = CustomMaterial.SurfaceShader(named: "wireframeMaterialSurfaceShader", in: library)
//        do {
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//
//            let material = try CustomMaterial(surfaceShader: surfaceShader, geometryModifier: geometryModifier, lightingModel: .clearcoat)
//            let material = try CustomMaterial(from: baseMaterial, surfaceShader: surfaceShader)
//            let material = try CustomMaterial(surfaceShader: surfaceShader, lightingModel: .unlit)
//
    // #if os(macOS)
//    let baseMaterial = SimpleMaterial(color: .lightGray, isMetallic: false)
    // #else
//    let baseMaterial = SimpleMaterial(color: .lightGray, isMetallic: false)
    // #endif
//        let generatedMeshBuffer = try! renderer.render(voxelData: voxels,
//                                                       scale: .init(),
//                                                       within: voxels.bounds.expand(2))
//
//        guard let descriptor = generatedMeshBuffer.meshDescriptor() else {
//            fatalError("Invalid mesh - no descriptor")
//        }
//        let mesh = try! MeshResource.generate(from: [descriptor])
//        let entity = ModelEntity(mesh: mesh, materials: [baseMaterial])
//        entity.name = "VoxelData"
//        return entity
//    }
}
