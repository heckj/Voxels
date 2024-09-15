import Heightmap
import Noise

public extension Heightmap {
    init(width: Int, height: Int, seed: Int) {
        var noisedata: [Float] = []
        let noise_low = GradientNoise2D(amplitude: 1, frequency: 0.01, seed: 235_926)
        let noise_med = GradientNoise2D(amplitude: 1, frequency: 0.1, seed: 235_926)
        let noise_high = GradientNoise2D(amplitude: 1, frequency: 1, seed: 235_926)
        // evaluation of noise results in a relatively slowly changing value between -1 and 1
        for linearIndex in 0 ..< (height * width) {
            let xzIndex = XZIndex.strideToXZ(linearIndex, width: width)
            let result = noise_low.evaluate(Double(xzIndex.x), Double(xzIndex.z)) + noise_med.evaluate(Double(xzIndex.x), Double(xzIndex.z)) * 0.1 // +
            // noise_high.evaluate(Double(xzIndex.x), Double(xzIndex.z)) * 0.05
            noisedata.append(Float((result + 1) / 2.0))
        }
        self.init(noisedata, width: width)
    }
}
