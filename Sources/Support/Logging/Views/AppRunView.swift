#if os(iOS)
#if canImport(SwiftUI)

import SwiftUI
import SwiftData

@available(iOS 26.0, *)
@available(macOS, unavailable)
struct AppRunView: View {
    @Query(filter: #Predicate<LogEntry> { entry in
        entry.subsystem != nil && entry.subsystem != "" && !(entry.subsystem?.contains("com.apple.") ?? false)
    }) var logEntries: [LogEntry]
    
    @State var isShowingMetadata = Set<Metadata>(Metadata.allCases)
    
    @State private var searchText = ""
    @State private var tokens: [SearchToken] = []
    @State private var filteredEntries: [LogEntry] = []
    @State private var groupedEntries: [AppRun: [LogEntry]] = [:]
    
    func filterEntries() {
        filteredEntries = logEntries.filter(searchText: searchText, tokens: tokens)
        groupedEntries = Dictionary(grouping: filteredEntries) { $0.appRun }
    }
    
    @ViewBuilder
    func appRunLogs(_ logs: [LogEntry]) -> some View {
        ForEach(logs) { entry in
            VStack(alignment: .leading) {
                Text(entry.composedMessage.highlighted(
                    matching: [searchText] + tokens.filter { $0.scope == .message }.map { $0.text }
                ))
                HStack {
                    if let level = entry.level, isShowingMetadata.contains(.level) {
                        Text(level.exportDescription.highlighted(
                            matching: [searchText] + tokens.filter { $0.scope == .level }.map { $0.text }
                        ))
                    }
                    
                    if isShowingMetadata.contains(.date) {
                        Text(entry.date.formatted())
                    }
                    
                    if let subsystem = entry.subsystem, isShowingMetadata.contains(.subsystem) {
                        Text(subsystem.highlighted(
                            matching: [searchText] + tokens.filter { $0.scope == .subsystem }.map { $0.text }
                        ))
                    }
                    
                    if let category = entry.category, isShowingMetadata.contains(.category) {
                        Text(category.highlighted(
                            matching: [searchText] + tokens.filter { $0.scope == .category }.map { $0.text }
                        ))
                    }
                }
                .font(.caption)
            }
        }
    }
    
    var appRunsList: some View {
        List {
            ForEach(groupedEntries.keys.sorted { $0.launchDate > $1.launchDate }, id: \.self) { appRun in
                Section(appRun.launchDate.formatted()) {
                    appRunLogs(groupedEntries[appRun]!.sorted { $0.date < $1.date })
                }
            }
        }
        .listStyle(.plain)
    }
    
    func suggestionText(for scope: SearchScope) -> some View {
        HStack {
            Text("\(Image(systemName: scope.image))").bold().foregroundStyle(.blue).frame(width: 30)
            Text("\(scope.rawValue.capitalized) contains: ").foregroundStyle(.secondary) + Text("\(searchText)")
        }
        .tint(.primary)
        .searchCompletion(SearchToken(searchText, in: scope))
    }
    
    var appRuns: some View {
        appRunsList
        .searchable(text: $searchText, tokens: $tokens) { token in
            HStack {
                Image(systemName: token.scope.filledImage)
                Text(token.text.lowercased())
            }
        }
        .searchSuggestions {
            if !searchText.isEmpty {
                Section("Suggestions") {
                    suggestionText(for: .message)
                    suggestionText(for: .level)
                    suggestionText(for: .subsystem)
                    suggestionText(for: .category)
                }
                Section("Results") {
                    appRunLogs(filteredEntries)
                }
            }
        }
    }
    
    var menu: some View {
        Menu {
            ForEach(Metadata.allCases, id: \.self) { metadata in
                Section {
                    Toggle(isOn: .init(get: { isShowingMetadata.contains(metadata) }, set: {
                        if $0 {
                            isShowingMetadata.insert(metadata)
                        } else {
                            isShowingMetadata.remove(metadata)
                        }
                    })) {
                        HStack {
                            Image(systemName: metadata.image)
                            Text("Show \(metadata.rawValue.capitalized)")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
        }
    }
    
    var body: some View {
        appRuns
        .onChange(of: logEntries, initial: true) {
            filterEntries()
        }
        .onChange(of: tokens) {
            filterEntries()
        }
        .onChange(of: searchText) {
            filterEntries()
        }
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarItem(placement: .topBarTrailing) {
                menu
            }
        }
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
