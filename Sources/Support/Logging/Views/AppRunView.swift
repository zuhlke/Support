#if os(iOS)
#if canImport(SwiftUI)

import SwiftUI
import SwiftData

struct Token: Identifiable, Equatable {
    var text: String
    var scope: Scope
    
    init(_ text: String, in scope: Scope) {
        self.text = text
        self.scope = scope
    }
    
    var id: String {
        text
    }
}

enum Scope: String, CaseIterable {
    case message, level, subsystem, category
}

extension Scope {
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
    func with(scope: Scope) -> String? {
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

@available(iOS 26.0, *)
@available(macOS, unavailable)
struct AppRunView: View {
    static let items = ["Level", "Date", "Subsystem", "Category"]

    @Query(filter: #Predicate<LogEntry> { entry in
        entry.subsystem != nil && entry.subsystem != "" && !(entry.subsystem?.contains("com.apple.") ?? false)
    }) var logEntries: [LogEntry]
    
    @State var isFilterMenuShown: Bool = false
    @State var selection = Set<String>(items)
    
    @State private var searchText = ""
    @State private var tokens: [Token] = []
    @State private var filteredEntries: [LogEntry] = []
    @State private var groupedEntries: [AppRun: [LogEntry]] = [:]
    
    func filterEntries() {
        var filteredEntries: [LogEntry] = logEntries
        
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
        
        self.filteredEntries = filteredEntries
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
                    if let level = entry.level, selection.contains("Level") {
                        Text(level.exportDescription.highlighted(
                            matching: [searchText] + tokens.filter { $0.scope == .level }.map { $0.text }
                        ))
                    }
                    if selection.contains("Date") {
                        Text(entry.date.formatted())
                    }
                    if let subsystem = entry.subsystem, selection.contains("Subsystem") {
                        Text(subsystem.highlighted(
                            matching: [searchText] + tokens.filter { $0.scope == .subsystem }.map { $0.text }
                        ))
                    }
                    if let category = entry.category, selection.contains("Category") {
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
    
    func suggestionText(for scope: Scope) -> some View {
        HStack {
            Text("\(Image(systemName: scope.image))").bold().foregroundStyle(.blue).frame(width: 30)
            Text("\(scope.rawValue.uppercased()) contains: ").foregroundStyle(.secondary) + Text("\(searchText)")
        }
        .tint(.primary)
        .searchCompletion(Token(searchText, in: scope))
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
            ToolbarSpacer(.flexible, placement: .bottomBar)
            if isFilterMenuShown {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm) {
                        isFilterMenuShown.toggle()
                    }
                }
            } else {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarItem(placement: .topBarTrailing) {
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
