#if os(iOS)
#if canImport(SwiftUI)

import SwiftUI
import SwiftData

struct Token: Identifiable {
    var name: String
    var id: String {
        name
    }
}

@available(iOS 26.0, *)
@available(macOS, unavailable)
struct AppRunView: View {
    @Query(sort: \LogEntry.date, order: .reverse) var logEntries: [LogEntry]
    
    @State var isFilterMenuShown: Bool = false
    static let items = ["Level", "Date", "Subsystem", "Category"]
    @State var selection = Set<String>(items)
    @State private var searchText = ""
    @State private var tokens: [Token] = []
        
    var filteredEntries: [LogEntry] {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let activeTokens = tokens.map { $0.name.lowercased() }
        
        return logEntries.filter { logEntry in
            guard !(logEntry.subsystem?.hasPrefix("com.apple.") ?? false) else { return false }
            
            let fields: [String] = [
                logEntry.composedMessage,
                logEntry.level?.exportDescription,
                logEntry.subsystem,
                logEntry.category
            ].compactMap { $0?.lowercased() }
            
            if !trimmedSearchText.isEmpty {
                let matchesText = fields.contains { $0.contains(trimmedSearchText) }
                if !matchesText { return false }
            }
            
            if !activeTokens.isEmpty {
                let matchesAllTokens = activeTokens.allSatisfy { token in
                    fields.contains { $0.contains(token) }
                }
                if !matchesAllTokens { return false }
            }
            
            return true
        }
    }
    
    var groupedEntries: [AppRun: [LogEntry]] {
        Dictionary(grouping: filteredEntries.filter {
            !($0.subsystem?.hasPrefix("com.apple.") ?? false) }
        ) { $0.appRun }
    }
    
    @ViewBuilder
    func appRunLogs(_ logs: [LogEntry]) -> some View {
        ForEach(logs) { entry in
            VStack(alignment: .leading) {
                Text(entry.composedMessage.highlighted(
                    matching: [searchText] + tokens.map { $0.name }
                ))
                HStack {
                    if let level = entry.level, selection.contains("Level") {
                        Text(level.exportDescription.highlighted(
                            matching: [searchText] + tokens.map { $0.name }
                        ))
                    }
                    if selection.contains("Date") {
                        Text(entry.date.formatted())
                    }
                    if let subsystem = entry.subsystem, selection.contains("Subsystem") {
                        Text(subsystem.highlighted(
                            matching: [searchText] + tokens.map { $0.name }
                        ))
                    }
                    if let category = entry.category, selection.contains("Category") {
                        Text(category.highlighted(
                            matching: [searchText] + tokens.map { $0.name }
                        ))
                    }
                }
                .font(.caption)
            }
        }
    }
    
    var appRuns: some View {
        List {
            ForEach(groupedEntries.keys.sorted { $0.launchDate > $1.launchDate }, id: \.self) { appRun in
                Section(appRun.launchDate.formatted()) {
                    appRunLogs(groupedEntries[appRun]!.sorted { $0.date < $1.date })
                }
            }
        }
    }
    
    var body: some View {
        appRuns
        .searchable(text: $searchText, editableTokens: $tokens) { $token in
            Text(token.name)
        }
        .onSubmit(of: .search) {
            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !trimmed.isEmpty else { return }
            
            let newToken = Token(name: trimmed)
            if !tokens.contains(where: { $0.id == newToken.id }) {
                tokens.append(newToken)
            }
            searchText = ""
        }
        .toolbar {
            ToolbarSpacer(.flexible, placement: .bottomBar)
            if isFilterMenuShown {
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .confirm) {
                        isFilterMenuShown.toggle()
                    }
                }
            } else {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        isFilterMenuShown.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }
        }
        .overlay {
            if isFilterMenuShown {
                List(Self.items, id: \.self, selection: $selection) {
                    Text("\($0)")
                }
                .environment(\.editMode, .constant(EditMode.active))
            }

        }
        .animation(.easeInOut, value: isFilterMenuShown)
    }
}

@available(iOS 26.0, *)
#Preview(traits: .sampleData) {
    NavigationStack {
        AppRunView()
    }
}

#endif
#endif
