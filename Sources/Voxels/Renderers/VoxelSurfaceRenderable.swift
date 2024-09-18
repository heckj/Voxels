public protocol VoxelSurfaceRenderable {
    func distanceAboveSurface() -> Float
}

extension Float: VoxelSurfaceRenderable {
    public func distanceAboveSurface() -> Float {
        self
    }
}
