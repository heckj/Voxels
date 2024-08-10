@testable import Voxels
import XCTest

class VoxelArrayTests: XCTestCase {
    func testVoxelArrayInitializer() throws {
        let v = VoxelArray(edge: 3, value: 1)

        // internal access
        XCTAssertEqual(v._contents.count, 27)
        for internalValue in v._contents {
            XCTAssertEqual(internalValue, 1)
        }

        // external access
        XCTAssertEqual(v.value(x: 0, y: 0, z: 0), 1)
        XCTAssertEqual(v.value(x: 1, y: 1, z: 1), 1)
        XCTAssertEqual(v.value(x: 2, y: 2, z: 2), 1)

        XCTAssertEqual(v.size, 27)
    }

    func testLinearize() throws {
        let v = VoxelArray(edge: 3, value: 1)

        // indexing function
        XCTAssertEqual(v.linearize(0, 0, 0), 0)
        XCTAssertEqual(v.linearize(1, 1, 1), 13)
        XCTAssertEqual(v.linearize(2, 2, 2), 26)
    }

    func testDelinearize() throws {
        let v = VoxelArray(edge: 3, value: 1)

        // reversing the indexing function
        XCTAssertEqual(v.delinearize(0), SIMD3<UInt>(0, 0, 0))
        XCTAssertEqual(v.delinearize(13), SIMD3<UInt>(1, 1, 1))
        XCTAssertEqual(v.delinearize(26), SIMD3<UInt>(2, 2, 2))
    }

    func testSIMDFloatDefault() throws {
        let x = SIMD8<Float>()
        XCTAssertEqual(x[0], 0)
    }
}
