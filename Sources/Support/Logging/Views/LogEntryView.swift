#if os(iOS)
#if canImport(SwiftUI)

import SwiftUI

struct LogEntryView: View {
    var entry: LogEntry
    var searchText: String
    var tokens: [SearchToken]
    var isShowingMetadata: Set<Metadata>
    
    func scopeSection(text: String, for scope: SearchScope) -> some View {
        HStack(spacing: 2) {
            Image(systemName: scope.image)
                .frame(width: 24, height: 24)
            Text(text.highlighted(
                matching: [searchText] + tokens.filter { $0.scope == scope }.map { $0.text }
            ))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.composedMessage.highlighted(
                matching: [searchText] + tokens.filter { $0.scope == .message }.map { $0.text }
            ))
            HStack(spacing: 8) {
                if let level = entry.level, isShowingMetadata.contains(.level) {
                    LevelView(level)
                }
                
                if isShowingMetadata.contains(.timestamp) {
                    Text(entry.date.formatted(.dateTime
                        .hour(.twoDigits(amPM: .omitted))
                        .minute(.twoDigits)
                        .second(.twoDigits)
                        .secondFraction(.fractional(4))
                    ))
                }
                
                if let subsystem = entry.subsystem, isShowingMetadata.contains(.subsystem) {
                    scopeSection(text: subsystem, for: .subsystem)
                }
                
                if let category = entry.category, isShowingMetadata.contains(.category) {
                    scopeSection(text: category, for: .category)
                }
            }
            .font(.caption)
        }
    }
}

#endif
#endif
