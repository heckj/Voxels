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
        XCTAssertEqual(try v.value(VoxelIndex(x: 0, y: 0, z: 0)), 1)
        XCTAssertEqual(try v.value(VoxelIndex(x: 1, y: 1, z: 1)), 1)
        XCTAssertEqual(try v.value(VoxelIndex(x: 2, y: 2, z: 2)), 1)

        XCTAssertEqual(v.size, 27)
    }

    func testLinearize() throws {
        let v = VoxelArray(edge: 3, value: 1)

        // indexing function
        XCTAssertEqual(try v.linearize(VoxelIndex(0, 0, 0)), 0)
        XCTAssertEqual(try v.linearize(VoxelIndex(1, 1, 1)), 13)
        XCTAssertEqual(try v.linearize(VoxelIndex(2, 2, 2)), 26)
    }

    func testDelinearize() throws {
        let v = VoxelArray(edge: 3, value: 1)

        guard let boundsCheck = v.bounds else {
            XCTFail("VoxelArray should never have null bounds")
            return
        }

        for linearIndex in 0 ..< v.size {
            let voxelIndex = try v.delinearize(linearIndex)
            // print("stride \(linearIndex) -> \(voxelIndex)")
            XCTAssertTrue(boundsCheck.contains(voxelIndex), "stride \(linearIndex) results in out of bounds index: \(voxelIndex)")
        }

        // reversing the indexing function
        XCTAssertEqual(try v.delinearize(0), VoxelIndex(0, 0, 0))
        XCTAssertEqual(try v.delinearize(13), VoxelIndex(1, 1, 1))
        XCTAssertEqual(try v.delinearize(26), VoxelIndex(2, 2, 2))
    }

    func testVoxelArraySequence() throws {
        var voxels = VoxelArray(edge: 3, value: 1)
        try voxels.set(VoxelIndex(1, 1, 1), newValue: 2)

        let ones = voxels.filter { $0 == 1 }
        XCTAssertEqual(ones.count, 26)

        let twos = voxels.filter { $0 == 2 }
        XCTAssertEqual(twos.count, 1)
    }

    func testVoxelOutOfBoundsAccess() throws {
        let voxels = VoxelArray(edge: 3, value: 1)
        XCTAssertThrowsError(try voxels.value(VoxelIndex(x: -1, y: 0, z: 0)))

        XCTAssertThrowsError(try voxels.value(VoxelIndex(x: 2, y: 2, z: 3)))
    }
}
