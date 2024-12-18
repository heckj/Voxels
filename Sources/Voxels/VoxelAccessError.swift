public import Foundation // for LocalizedError

public enum VoxelAccessError: Error {
    case outOfBounds(_ msg: String)
    case missingVoxelData(_ msg: String)
}

extension VoxelAccessError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .outOfBounds(msg):
            msg
        case let .missingVoxelData(msg):
            msg
        }
    }
}
