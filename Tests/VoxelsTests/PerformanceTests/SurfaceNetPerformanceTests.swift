import Voxels
import XCTest

final class SurfaceNetPerformanceTests: XCTestCase {
    func testPerformanceInitialSurfaceNetPort() throws {
        let samples = try SampleMeshData.voxelArrayFromSphere()

        let bounds = samples.bounds.insetQuadrant()
        // 0.189 sec - original // initial 0.220
        // changing corners: 0.183, 0.184 // initial 0.216

        // battery only: 0.295
        measure {
            _ = try! VoxelMeshRenderer.surfaceNetMesh(sdf: samples, within: bounds)
        }
    }

    func testPerformanceRemadeSurfaceNetPort() throws {
        let samples = try SampleMeshData.voxelArrayFromSphere()

        let bounds = samples.bounds.insetQuadrant()
        // 0.163, 0.165 sec - so very much on par with the original

        // battery only: 0.305
        measure {
            let thing = SurfaceNetRenderer()
            _ = try! thing.render(voxelData: samples, scale: .init(), within: bounds)
        }
    }

    func testBoundsIndices() throws {
        let bounds = VoxelBounds(min: VoxelIndex(0, 0, 0), max: VoxelIndex(32, 32, 32))

        // 0.012
        measure {
            _ = bounds.indices
        }
    }
}
