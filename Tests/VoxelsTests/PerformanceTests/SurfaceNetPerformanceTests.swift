import Voxels
import XCTest

final class SurfaceNetPerformanceTests: XCTestCase {
    func testPerformanceRemadeSurfaceNetPort() throws {
        let samples = try SampleMeshData.voxelArrayFromSphere()

        let bounds = samples.bounds.insetQuadrant()
        // 0.23 -> 0.193 by not returning the data and inserting as a side effect...
        measure {
            let thing = SurfaceNetRenderer()
            _ = thing.render(samples, scale: .init(), within: bounds)
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
