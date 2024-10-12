public extension VoxelAccessible where Element: VoxelBlockRenderable {
    func isSurface(_ tuple: (Int, Int, Int)) -> Bool {
        isSurface(VoxelIndex(tuple))
    }

    func isSurface(_ vindex: VoxelIndex) -> Bool {
        guard let voxel = self[vindex], voxel.isOpaque() else {
            return false
        }

        let distance1neighbors = [
            VoxelIndex(0, 0, 1),
            VoxelIndex(0, 0, -1),
            VoxelIndex(0, 1, 0),
            VoxelIndex(0, -1, 0),
            VoxelIndex(1, 0, 0),
            VoxelIndex(-1, 0, 0),
        ]

        let sumOpaqueNeighbors = distance1neighbors.reduce(into: 0) { partialResult, locationOffset in
            let indexInCollection = VoxelIndex(x: vindex.x + locationOffset.x, y: vindex.y + locationOffset.y, z: vindex.z + locationOffset.z)
            if let voxel = self[indexInCollection], voxel.isOpaque() {
                partialResult += 1
            }
        }
        return sumOpaqueNeighbors != 6
    }

    func isSurfaceFace(_ vindex: VoxelIndex, direction: CubeFace) -> Bool {
        let secondIndex = vindex.adding(direction.voxelIndexOffset)
        if let firstVoxel = self[vindex] {
            // first voxel returned a value
            if let secondVoxel = self[secondIndex] {
                return firstVoxel.isOpaque() != secondVoxel.isOpaque()
            } else {
                // second voxel didn't return a value, treat as though its not opaque
                return firstVoxel.isOpaque()
            }
        } else {
            // first voxel didn't return a value
            if let secondVoxel = self[secondIndex], secondVoxel.isOpaque() {
                return true
            } else {
                return false
            }
        }
    }
}
