/// The collection of voxel index offsets for the corners of a voxel.
///
/// The relative offset by index for the corners:
///
///         ^ +Y
///         |
///     (2) +-----------------+ (3)
///         |\                 \
///         | \                 \
///         |  \                 \
///         |   \                 \
///         |    +-----------------+ (7)
///         |    |(6)              |
///         |    |                 |
///     (0) +    |            +    |-------> +X
///          \   |           (1)   |
///           \  |                 |
///            \ |                 |
///             \|                 |
///              +-----------------+
///           (4) \               (5)
///                \
///                _\/
///                  +Z
/// ```

public let CUBE_CORNERS: [VoxelIndex] = [
    [0, 0, 0], // back, bottom, left
    [1, 0, 0], // back, bottom, right
    [0, 1, 0], // back, top, left
    [1, 1, 0], // back, top, right
    [0, 0, 1], // front, bottom, left
    [1, 0, 1], // front, bottom, right
    [0, 1, 1], // front, top, left
    [1, 1, 1], // front, top, right
]

let CUBE_CORNER_VECTORS: [SIMD3<Float>] = [
    [0.0, 0.0, 0.0],
    [1.0, 0.0, 0.0],
    [0.0, 1.0, 0.0],
    [1.0, 1.0, 0.0],
    [0.0, 0.0, 1.0],
    [1.0, 0.0, 1.0],
    [0.0, 1.0, 1.0],
    [1.0, 1.0, 1.0],
]

let CUBE_EDGES: [SIMD2<Int>] = [
    [0b000, 0b001], // 0, 1 - referencing cube corner index positions
    [0b000, 0b010], // 0, 2
    [0b000, 0b100], // 0, 4
    [0b001, 0b011], // 1, 3
    [0b001, 0b101], // 1, 5
    [0b010, 0b011], // 2, 3
    [0b010, 0b110], // 2, 6
    [0b011, 0b111], // 3, 7
    [0b100, 0b101], // 4, 5
    [0b100, 0b110], // 4, 6
    [0b101, 0b111], // 5, 7
    [0b110, 0b111], // 6, 7
]

/// The set of cube faces and relevant directions and coordinates of those faces.
///
/// The coordinate structure for the resulting offsets assumes a right-handed, Y-up coordinate system with a default view looking down the -Z direction.
///
/// ```
/// Coordinates and corners offsets
///         ^ +Y
///         |
/// (0,1,0) +-----------------+ (1,1,0)
///         |\                 \
///         | \                 \
///         |  \                 \
///         |   \                 \
///         |    +-----------------+ (1,1,1)
///         |    |(0,1,1)          |
///         |    |                 |
/// (0,0,0) +    |            +    |-------> +X
///          \   |       (1,0,0)   |
///           \  |                 |
///            \ |                 |
///             \|                 |
///              +-----------------+
///       (0,0,1) \         (1,0,1)
///                \
///                _\/
///                  +Z
/// ```
public enum CubeFace: UInt8, CaseIterable, Sendable {
    case y = 0 // up/top
    case yneg = 1 // down/below
    case x = 2 // right
    case xneg = 3 // left
    case z = 4 // backwards
    case zneg = 5 // forwards

    /// The relative offset to the next voxel when you use face a direction.
    @inlinable
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

    /// Returns a set of VoxelIndex offsets for the four corners of the face, in the winding order to create a 3D mesh quad from two triangles.
    /// - Parameters:
    ///   - face: The direction of the voxel's face.
    ///   - exterior: A Boolean value that indicates wether the quad is viewed from the exterior of the voxel.
    ///
    /// The coordinate structure for the resulting offsets assumes a right-handed, Y-up coordinate system with a default view looking down the -Z direction.
    ///
    /// The points of the Quad, viewed face-front, are 'wound' in the following order:
    ///  ```
    ///  v1  v3
    ///   | /|
    ///   |/ |
    ///  v2  v4
    /// ```
    @inlinable
    public func corners(exterior: Bool = true) -> [VoxelIndex] {
        switch (self, exterior) {
        case (.y, true): // aka "top", order viewed when looking "in"
            [[0, 1, 0], [0, 1, 1], [1, 1, 0], [1, 1, 1]]
        case (.y, false): // aka "top", order viewed when looking "out"
            [[0, 1, 1], [0, 1, 0], [1, 1, 1], [1, 1, 0]]
        case (.yneg, true): // "bottom", order viewed when looking "in"
            [[0, 0, 1], [0, 0, 0], [1, 0, 1], [1, 0, 0]]
        case (.yneg, false): // "bottom", order viewed when looking "out"
            [[0, 0, 0], [0, 0, 1], [1, 0, 0], [1, 0, 1]]
        case (.x, true): // "right", order viewed when looking "in"
            [[1, 0, 0], [1, 1, 0], [1, 0, 1], [1, 1, 1]]
        case (.x, false): // "right",order viewed when looking "out"
            [[1, 0, 1], [1, 1, 1], [1, 0, 0], [1, 1, 0]]
        case (.xneg, true): // "left", order viewed when looking "in"
            [[0, 0, 1], [0, 1, 1], [0, 0, 0], [0, 1, 0]]
        case (.xneg, false): // "left", order viewed when looking "out"
            [[0, 0, 0], [0, 1, 0], [0, 0, 1], [0, 1, 1]]
        case (.z, true): // "front", order viewed when looking "in"
            [[0, 1, 1], [0, 0, 1], [1, 1, 1], [1, 0, 1]]
        case (.z, false): // "front", order viewed when looking "out"
            [[1, 1, 1], [1, 0, 1], [0, 1, 1], [0, 0, 1]]
        case (.zneg, true): // "back", order viewed when looking "in"
            [[1, 1, 0], [1, 0, 0], [0, 1, 0], [0, 0, 0]]
        case (.zneg, false): // "back", order viewed when looking "out"
            [[0, 1, 0], [0, 0, 0], [1, 1, 0], [1, 0, 0]]
        }
    }
}

extension CubeFace: CustomStringConvertible {
    /// A description of the face in RealityView coordinates axis directions.
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
