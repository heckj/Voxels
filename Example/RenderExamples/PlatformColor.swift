#if os(iOS)
    import UIKit

    typealias PlatformColor = UIColor
#elseif os(macOS)
    import AppKit

    typealias PlatformColor = NSColor
#endif
