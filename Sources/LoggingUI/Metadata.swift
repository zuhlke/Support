#if os(iOS)

import Foundation

enum Metadata: String, CaseIterable {
    case level, timestamp, subsystem, category
}

extension Metadata {
    var image: String {
        switch self {
        case .level:
            "flag"
        case .timestamp:
            "clock"
        case .subsystem:
            "gearshape.2"
        case .category:
            "square.grid.3x3"
        }
    }
}

#endif
