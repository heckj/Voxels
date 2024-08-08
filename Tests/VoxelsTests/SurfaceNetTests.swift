@testable import Voxels
import XCTest

final class SurfaceNetTests: XCTestCase {
    func testExample() throws {
        // Based on the example usage of the original library at https://github.com/bonsairobo/fast-surface-nets-rs/blob/main/examples-crate/render/main.rs

        let sphereSDF: SDFSampleable<Float> = SDF.sphere()

        let sampleShape = VoxelArray<UInt32>(size: 34, value: 0)
        var samples: [Float] = Array(repeating: 0.0, count: sampleShape.size)

        for i in 0 ..< (sampleShape.size) {
            let position: SIMD3<Float> = into_domain(array_dim: 32, sampleShape.delinearize(UInt(i)))
            let value = sphereSDF.valueAt(position)
            samples[i] = value
        }

        let insides = samples.filter { val in
            val < 0
        }
        XCTAssertTrue(insides.count > 1)

        let buffer = surface_nets(
            sdf: samples,
            shape: sampleShape,
            min: SIMD3<UInt32>(0, 0, 0),
            max: SIMD3<UInt32>(33, 33, 33)
        )

        XCTAssertTrue(buffer.positions.count > 1)
    }

    func testSphereSDFMeasures() throws {
        let sphereSDF = SDF.sphere()

        XCTAssertEqual(sphereSDF.valueAt(x: 0, y: 0, z: 0), -0.5)
        XCTAssertEqual(sphereSDF.valueAt(x: 0.25, y: 0, z: 0), -0.25)
        XCTAssertEqual(sphereSDF.valueAt(x: 0.5, y: 0, z: 0), 0)
        XCTAssertEqual(sphereSDF.valueAt(x: 1, y: 0, z: 0), 0.5)
    }

    func into_domain(array_dim: UInt, _ xyz: SIMD3<UInt>) -> SIMD3<Float> {
        // samples over a quadrant - starts at -1 and goes up to (2/edgeSize * (edgeSize-1)) - 1
        (2.0 / Float(array_dim)) * SIMD3<Float>(Float(xyz.x), Float(xyz.y), Float(xyz.z)) - 1.0
    }

//    func testIntoDomain() throws {
//        let sampleShape = VoxelArray<Int>(size: 3, value: 3)
//        let position: SIMD3<Float> = into_domain(array_dim: UInt(sampleShape.edgeSize), sampleShape.delinearize(UInt(0)))
//        print(position)
//    }
}