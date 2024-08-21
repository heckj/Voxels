public struct VoxelScale<T: SIMDScalar> {
    
    public let origin: SIMD3<T>
    public let cubeSize: T
    
    public init(origin: SIMD3<T>, cubeSize: T) {
        self.origin = origin
        self.cubeSize = cubeSize
    }
    
    public func centroidPosition(_ index: VoxelIndex) -> SIMD3<T> where T: BinaryFloatingPoint {
        return cornerPosition(index) + SIMD3<T>(repeating: cubeSize/2.0)
    }
    
    public func cornerPosition(_ index: VoxelIndex) -> SIMD3<T> where T: BinaryFloatingPoint {
        return origin + SIMD3<T>(x: T(index.x), y: T(index.y), z: T(index.z))*cubeSize
    }

    public func cornerPosition(_ index: VoxelIndex) -> SIMD3<T> where T: FixedWidthInteger {
        return SIMD3<T>(x: origin.x + (T(index.x) * cubeSize),
                        y: origin.y + (T(index.y) * cubeSize),
                        z: origin.z + (T(index.z) * cubeSize))
    }
}
