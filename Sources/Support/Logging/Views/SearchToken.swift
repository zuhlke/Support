#if os(iOS)

import Foundation

struct SearchToken: Identifiable, Equatable {
    var text: String
    var scope: SearchScope
    
    init(_ text: String, in scope: SearchScope) {
        self.text = text
        self.scope = scope
    }
    
    var id: String {
        text
    }
}

enum SearchScope: String, CaseIterable {
    case message, level, subsystem, category
}

extension SearchScope {
    var image: String {
        switch self {
        case .message:
            return "bubble"
        case .level:
            return "flag"
        case .subsystem:
            return "puzzlepiece"
        case .category:
            return "tag"
        }
    }
    
    var filledImage: String {
        "\(image).fill"
    }
}

extension LogEntry {
    func with(scope: SearchScope) -> String? {
        switch scope {
        case .message:
            return composedMessage
        case .level:
            return level?.exportDescription
        case .subsystem:
            return subsystem
        case .category:
            return category
        }
        return nil
    }
}

#endif
