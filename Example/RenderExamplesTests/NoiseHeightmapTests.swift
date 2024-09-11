import Heightmap
import Noise
import XCTest

final class NoiseRangeTests: XCTestCase {
    func testNoiseAmplitudeRange() throws {
        let noise = GradientNoise2D(amplitude: 1, frequency: 0.01, seed: 235_926)
        var min = 0.0
        var max = 0.0
        for i: Int in 0 ... 100_000 {
            let result = noise.evaluate(0, Double(i))
            // print(result)
            min = Swift.min(result, min)
            max = Swift.max(result, max)
        }
        // print(min, max)
        XCTAssertTrue(max < 1.0)
        XCTAssertTrue(min > -1.0)
    }

    func testHeightmapInitWithNoise() throws {
        let h = Heightmap(width: 10, height: 10, seed: 346)
        XCTAssertEqual(h.width, 10)
        XCTAssertEqual(h.height, 10)
        XCTAssertEqual(h.contents.count, 100)
    }
}
