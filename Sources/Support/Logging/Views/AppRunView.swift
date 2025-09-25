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
    static let items = ["Level", "Date", "Subsystem", "Category"]

    @Query(sort: \LogEntry.date, order: .reverse) var logEntries: [LogEntry]
    
    @State var isFilterMenuShown: Bool = false
    @State var selection = Set<String>(items)
    @State private var searchText = ""
    @State private var tokens: [Token] = []
    @State private var groupedEntries: [AppRun: [LogEntry]] = [:]
        
    func updateGroupedEntries() {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let filteredEntries = logEntries.filter { logEntry in
            guard !(logEntry.subsystem?.hasPrefix("com.apple.") ?? false) else { return false }
            
            let fields: [String] = [
                logEntry.composedMessage,
                logEntry.level?.exportDescription,
                logEntry.subsystem,
                logEntry.category
            ].compactMap { $0?.lowercased() }
            
            if !trimmedSearchText.isEmpty {
                let matchesText = fields.contains { $0.localizedCaseInsensitiveContains(trimmedSearchText) }
                if !matchesText { return false }
            }
            
            if !tokens.isEmpty {
                let matchesAllTokens = tokens.allSatisfy { token in
                    fields.contains { $0.localizedCaseInsensitiveContains(token.name) }
                }
                if !matchesAllTokens { return false }
            }
            
            return true
        }
        
        groupedEntries = Dictionary(grouping: filteredEntries) { $0.appRun }
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
            let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !trimmedSearchText.isEmpty else { return }
            
            let newToken = Token(name: trimmedSearchText)
            if !tokens.contains(where: { $0.id == newToken.id }) {
                tokens.append(newToken)
            }
            searchText = ""
        }
        .onChange(of: searchText) {
            updateGroupedEntries()
        }
        .onChange(of: logEntries, initial: true) {
            updateGroupedEntries()
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
