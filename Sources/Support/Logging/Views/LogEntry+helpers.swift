#if LoggingFeature
#if os(iOS)
#if canImport(SwiftUI)

import Foundation
import SwiftUI

extension [LogEntry] {
    func filter(searchText: String, tokens: [SearchToken]) -> [LogEntry] {
        var filteredEntries: [LogEntry] = self
        
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmedSearchText.isEmpty {
            filteredEntries = filteredEntries.filter { logEntry in
                let fields: [String] = [
                    logEntry.composedMessage,
                    logEntry.level?.exportDescription,
                    logEntry.subsystem,
                    logEntry.category
                ].compactMap { $0 }
                
                return fields.contains { $0.localizedCaseInsensitiveContains(trimmedSearchText) }
            }
        }
        
        if !tokens.isEmpty {
            filteredEntries = filteredEntries.filter { logEntry in
                tokens.allSatisfy { token in
                    logEntry.with(scope: token.scope)?.localizedCaseInsensitiveContains(token.text) ?? false
                }
            }
        }
        
        return filteredEntries
    }
}

extension LogEntry {
    @ViewBuilder
    var background: some View {
        switch level {
        case .error:
            Color.yellow.opacity(0.2)
        case .fault:
            Color.red.opacity(0.2)
        default:
            Color.white
        }
    }
    
    func scope(_ scope: SearchScope) -> String? {
        switch scope {
        case .level:
            return level?.exportDescription
        case .category:
            return category
        case .subsystem:
            return subsystem
        case .message:
            return composedMessage
        }
    }
}

#endif
#endif
#endif
