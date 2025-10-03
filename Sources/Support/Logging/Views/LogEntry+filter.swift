import Foundation

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
