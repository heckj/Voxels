public import Foundation

public enum HeightmapError: LocalizedError {
    case invalid(_ msg: String)

    public var errorDescription: String? {
        switch self {
        case let .invalid(msg):
            msg
        }
    }
}
