/// A type that can be rendered as opaque blocks.
public protocol VoxelBlockRenderable {
    func isOpaque() -> Bool
}

extension Float: VoxelBlockRenderable {
    public func isOpaque() -> Bool {
        self < 0
    }
}

extension Int: VoxelBlockRenderable {
    public func isOpaque() -> Bool {
        self > 0
    }
}
