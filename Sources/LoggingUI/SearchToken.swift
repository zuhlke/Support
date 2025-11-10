#if canImport(Darwin)

import Foundation
import OSLog
import Support

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
            "bubble"
        case .level:
            "flag"
        case .subsystem:
            "gearshape.2"
        case .category:
            "square.grid.3x3"
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
            composedMessage
        case .level:
            level?.exportDescription
        case .subsystem:
            subsystem
        case .category:
            category
        }
    }
}

// TODO: (P3) - This was duplicated from `LogEntry` so we don't expose it to public.
// Review if we can remove one of these.
extension OSLogEntryLog.Level {
    var exportDescription: String {
        switch self {
        case .undefined: "undefined"
        case .debug: "debug"
        case .info: "info"
        case .notice: "notice"
        case .error: "error"
        case .fault: "fault"
        @unknown default: "unknown: \(rawValue)"
        }
    }
}

#endif
