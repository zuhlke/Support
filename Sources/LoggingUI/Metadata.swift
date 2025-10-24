#if os(iOS)

import Foundation

enum Metadata: String, CaseIterable {
    case level, timestamp, subsystem, category
}

extension Metadata {
    var image: String {
        switch self {
        case .level:
            return "flag"
        case .timestamp:
            return "clock"
        case .subsystem:
            return "gearshape.2"
        case .category:
            return "square.grid.3x3"
        }
    }
}

#endif
