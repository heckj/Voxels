import Heightmap
import RealityKit
import RenderExamples
import Voxels
import XCTest

final class GeneralMeasurementTests: XCTestCase {
    func testGenerateHeightmap() throws {
        // ~ 0.361 seconds (full power, not battery)
        measure {
            let _ = Heightmap(width: 500, height: 500, seed: 437_347_632)
        }
    }

    func testGenerateVoxelHeightmap() throws {
        let heightmap = Heightmap(width: 500, height: 500, seed: 437_347_632)

        // ~ 10.9 seconds (full power, not battery)
        measure {
            let _ = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 200, voxelSize: 1.0)
        }
    }

    func testSurfaceNetRenderVoxelizedHeightmap() throws {
        let heightmap = Heightmap(width: 100, height: 100, seed: 437_347_632)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 100, voxelSize: 1.0)

        // ~ 6.1 seconds (full power, not battery)
        measure {
            let _ = try! SurfaceNetRenderer().render(voxelData: voxels,
                                                     scale: .init(),
                                                     within: voxels.bounds)
        }
    }

    func testMarchingCubesRenderVoxelizedHeightmap() throws {
        let heightmap = Heightmap(width: 100, height: 100, seed: 437_347_632)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 100, voxelSize: 1.0)

        // ~ 4.37 seconds (full power, not battery)
        measure {
            let _ = MarchingCubesRenderer().render(voxels, scale: .init(), within: voxels.bounds.expand())
        }
    }

    func testBlockMeshRenderVoxelizedHeightmap() throws {
        let heightmap = Heightmap(width: 100, height: 100, seed: 437_347_632)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 100, voxelSize: 1.0)

        // ~ 0.91 seconds (full power, not battery)
        measure {
            let _ = BlockMeshRenderer().render(voxels, scale: .init(), within: voxels.bounds, surfaceOnly: true)
        }
    }

    func testNoiseHeightmapInitSpeed() throws {
        // ~ 1.4 sec (full power, not battery)
        measure {
            let _ = Heightmap(width: 1000, height: 1000, seed: 23623)
        }
    }

    func testSurfaceNetTimesAndSizes() throws {
        let heightmap = Heightmap(width: 1025, height: 1025, seed: 437_347_632)
        let voxels = HeightmapConverter.heightmap(heightmap, maxVoxelIndex: 50, voxelSize: 1.0)
        let clock = ContinuousClock()

        for edge in [2, 4, 5, 8, 10, 16, 20, 25, 32, 50, 64, 100, 128, 200, 256, 500, 512] {
            let bounds = VoxelBounds(min: .zero, max: VoxelIndex(edge, 50, edge))

            let start = clock.now
            let mesh = try! SurfaceNetRenderer().render(voxelData: voxels,
                                                        scale: .init(),
                                                        within: bounds)
            let duration = clock.now - start
            print("SurfaceNet render of \(edge) x \(edge): \(duration) generating \(mesh.memSize) bytes")

            // SurfaceNet render of 2 x 2: 0.005755292 seconds generating 1344 bytes
            // SurfaceNet render of 4 x 4: 0.015406125 seconds generating 3792 bytes
            // SurfaceNet render of 5 x 5: 0.022032375 seconds generating 5776 bytes
            // SurfaceNet render of 8 x 8: 0.050679041 seconds generating 13312 bytes
            // SurfaceNet render of 10 x 10: 0.074064792 seconds generating 19936 bytes
            // SurfaceNet render of 16 x 16: 0.176517458 seconds generating 47024 bytes
            // SurfaceNet render of 20 x 20: 0.267093417 seconds generating 70736 bytes
            // SurfaceNet render of 25 x 25: 0.409729833 seconds generating 107168 bytes
            // SurfaceNet render of 32 x 32: 0.657724916 seconds generating 179632 bytes
            // SurfaceNet render of 50 x 50: 1.584985084 seconds generating 444784 bytes
            // SurfaceNet render of 64 x 64: 2.579273625 seconds generating 718752 bytes
            // SurfaceNet render of 100 x 100: 6.270041958 seconds generating 1720992 bytes
            // SurfaceNet render of 128 x 128: 10.216252583000001 seconds generating 2788480 bytes
            // SurfaceNet render of 200 x 200: 25.034401374999998 seconds generating 6743784 bytes
            // SurfaceNet render of 256 x 256: 40.999645208000004 seconds generating 11105272 bytes
            // SurfaceNet render of 500 x 500: 156.528687625 seconds generating 42242680 bytes
            // SurfaceNet render of 512 x 512: 164.07509004200003 seconds generating 44285944 bytes
        }
    }
}
