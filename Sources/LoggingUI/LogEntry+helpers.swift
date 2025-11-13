#if canImport(Darwin)

import Foundation
import Support
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
                    logEntry.category,
                ].compactMap(\.self)
                
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
            level?.exportDescription
        case .category:
            category
        case .subsystem:
            subsystem
        case .message:
            composedMessage
        }
    }
}

#endif
