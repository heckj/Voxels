import SwiftUI
import Voxels

@main
struct VoxelRenderExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    func sdf_to_buffer(sdf: SDFWrapper<Float>) -> SurfaceNetsBuffer {
        let sampleShape = VoxelArray<UInt32>(size: 34, value: 0)
        var samples: [Float] = Array(repeating: 0.0, count: sampleShape.size)

        // sample the SDF into a collection of voxels
        for i in 0 ..< (sampleShape.size) {
            let position: SIMD3<Float> = into_domain(array_dim: 32, sampleShape.delinearize(UInt(i)))
            samples[i] = sdf.valueAt(position)
        }

        // generate the surface mesh(es) from the voxel array
        return surface_nets(
            sdf: samples,
            shape: sampleShape,
            min: SIMD3<UInt32>(0, 0, 0),
            max: SIMD3<UInt32>(33, 33, 33)
        )
    }

    func into_domain(array_dim: UInt, _ xyz: SIMD3<UInt>) -> SIMD3<Float> {
        // samples over a quadrant - starts at -1 and goes up to (2/edgeSize * (edgeSize-1)) - 1
        (2.0 / Float(array_dim)) * SIMD3<Float>(Float(xyz.x), Float(xyz.y), Float(xyz.z)) - 1.0
    }

    func sphere(radius: Float, p: Vector) -> Float {
        p.length - radius
    }
}
