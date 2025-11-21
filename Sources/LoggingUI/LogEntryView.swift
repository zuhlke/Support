#if canImport(Darwin)

import Support
import SwiftUI

public struct LogEntryView: View {
    var entry: LogEntry
    var searchText: String
    var tokens: [SearchToken]
    var isShowingMetadata: Set<Metadata>
    var shouldShowExpandedMessages: Bool
    
    @State private var isCollapsed: Bool = true
    
    func scopeSection(text: String, for scope: SearchScope) -> some View {
        HStack(spacing: 2) {
            Image(systemName: scope.image)
                .frame(width: 24, height: 24)
            Text(text.highlighted(
                matching: [searchText] + tokens.filter { $0.scope == scope }.map(\.text),
            ))
        }
    }
    
    public var body: some View {
        Button {
            isCollapsed.toggle()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.composedMessage.highlighted(
                    matching: [searchText] + tokens.filter { $0.scope == .message }.map(\.text),
                ))
                .lineLimit(isCollapsed ? 2 : nil)
                HStack(spacing: 8) {
                    if let level = entry.level, isShowingMetadata.contains(.level) {
                        LevelView(level)
                    }
                    
                    if isShowingMetadata.contains(.timestamp) {
                        Text(entry.date.formatted(
                            .dateTime
                                .hour(.twoDigits(amPM: .omitted))
                                .minute(.twoDigits)
                                .second(.twoDigits)
                                .secondFraction(.fractional(4)),
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
        .buttonStyle(.plain)
        .animation(.linear, value: isCollapsed)
        .onChange(of: shouldShowExpandedMessages) {
            isCollapsed = !$0
        }
    }
}

@available(iOS 26.0, *)
#Preview {
    let launchDate = Date()
    
    let appRun = AppRun(appVersion: "1.0.0", operatingSystemVersion: "14.0.0", launchDate: launchDate, device: "iPhone 12 Pro Max")
    
    let logEntry = LogEntry(appRun: appRun, date: launchDate.advanced(by: 1 * 60), composedMessage: "This is a really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really really long message", level: .info, category: "App", subsystem: "com.zuhlke.test")
    
    LogEntryView(entry: logEntry, searchText: "", tokens: [], isShowingMetadata: .init(Metadata.allCases), shouldShowExpandedMessages: false)
        .padding(16)
}

#endif
