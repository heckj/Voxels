protocol VoxelAccess {
    associatedtype Element
    func value(x: UInt, y: UInt, z: UInt) -> Element
}
