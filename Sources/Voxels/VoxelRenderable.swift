public protocol VoxelRenderable {
    func isOpaque() -> Bool
    func distanceAboveSurface() -> Float
    // consider adding a color type here?
}

extension Float: VoxelRenderable {
    public func isOpaque() -> Bool {
        self < 0
    }

    public func distanceAboveSurface() -> Float {
        self
    }
}

extension Int: VoxelRenderable {
    public func isOpaque() -> Bool {
        self > 0
    }

    public func distanceAboveSurface() -> Float {
        Float(-self)
    }
}
