import Foundation

enum Metadata: String, CaseIterable {
    case level, date, subsystem, category
}

extension Metadata {
    var image: String {
        switch self {
        case .level:
            return "flag"
        case .date:
            return "calendar"
        case .subsystem:
            return "puzzlepiece"
        case .category:
            return "tag"
        }
    }
}
