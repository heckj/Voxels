public let CUBE_CORNERS: [VoxelIndex] = [
    [0, 0, 0],
    [1, 0, 0],
    [0, 1, 0],
    [1, 1, 0],
    [0, 0, 1],
    [1, 0, 1],
    [0, 1, 1],
    [1, 1, 1],
]

public enum CubeFace: UInt8, CaseIterable {
    case y = 0 // up/top
    case yneg = 1 // down/below
    case x = 2 // right
    case xneg = 3 // left
    case z = 4 // backwards
    case zneg = 5 // forwards

    /// The voxel index offset advancing one step in the direction of the face.
    var voxelIndexOffset: VoxelIndex {
        switch self {
        case .y:
            VoxelIndex(0, 1, 0)
        case .yneg:
            VoxelIndex(0, -1, 0)
        case .x:
            VoxelIndex(1, 0, 0)
        case .xneg:
            VoxelIndex(-1, 0, 0)
        case .z:
            VoxelIndex(0, 0, 1)
        case .zneg:
            VoxelIndex(0, 0, -1)
        }
    }
}

extension CubeFace: CustomStringConvertible {
    /// A description of the face in RealityView coordinates axis directions
    public var description: String {
        switch self {
        case .y:
            "up"
        case .yneg:
            "down"
        case .x:
            "right"
        case .xneg:
            "left"
        case .zneg:
            "forwards"
        case .z:
            "backwards"
        }
    }
}
