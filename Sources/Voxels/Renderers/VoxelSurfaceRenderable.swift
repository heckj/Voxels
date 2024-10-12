/// A type that can be rendered as a surface.
public protocol VoxelSurfaceRenderable {
    func distanceAboveSurface() -> Float
}

extension Float: VoxelSurfaceRenderable {
    @inlinable
    public func distanceAboveSurface() -> Float {
        self
    }
}
