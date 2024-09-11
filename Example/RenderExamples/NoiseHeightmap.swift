import Heightmap
import Noise

public extension Heightmap {
    init(width: Int, height: Int, seed: Int) {
        var noisedata: [Float] = []
        let noise = GradientNoise2D(amplitude: 1, frequency: 0.01, seed: 235_926)
        // evaluation of noise results in a relatively slowly changing value between -1 and 1
        for linearIndex in 0 ..< (height * width) {
            let xzIndex = XZIndex.strideToXZ(linearIndex, width: width)
            let result = noise.evaluate(Double(xzIndex.x), Double(xzIndex.z))
            noisedata.append(Float((result + 1) / 2.0))
        }
        self.init(noisedata, width: width)
    }
}
