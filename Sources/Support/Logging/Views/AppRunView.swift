import SwiftUI
import SwiftData
import Support

struct Token: Identifiable {
    var id: String { name }
    var name: String
}

@available(iOS 26.0, *)
struct AppRunView: View {
    @Query(sort: \LogEntry.date, order: .reverse) var logEntries: [LogEntry]
    
    @State var isFilterMenuShown: Bool = false
    let items = ["Level", "Date", "Subsystem", "Category"]
    @State var selection = Set<String>(["Level", "Date", "Subsystem", "Category"])
    @State private var searchText = ""
    @State private var currentTokens = [Token]()
    let tokens: [String] = ["notice"]
    
    var filteredEntries: [LogEntry] {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespaces)
        
        return logEntries.filter { logEntry in
            if !searchText.isEmpty {
                if logEntry.composedMessage.localizedCaseInsensitiveContains(trimmedSearchText) {
                    return true
                }
                
                if let level = logEntry.level, level.exportDescription.localizedCaseInsensitiveContains(trimmedSearchText) {
                    return true
                }
                
                if let subsystem = logEntry.subsystem, subsystem.localizedCaseInsensitiveContains(trimmedSearchText) {
                    return true
                }
                
                if let category = logEntry.category, category.localizedCaseInsensitiveContains(trimmedSearchText) {
                    return true
                }
                return false
            }
            return true
        }
    }

    
    var groupedEntries: [AppRun: [LogEntry]] {
        Dictionary(grouping: filteredEntries.filter {
            !($0.subsystem?.hasPrefix("com.apple.") ?? false) }
        ) { $0.appRun }
    }
    
    var body: some View {
        List {
            ForEach(groupedEntries.keys.sorted { $0.launchDate > $1.launchDate }, id: \.self) { appRun in
                Section(appRun.launchDate.formatted()) {
                    ForEach(groupedEntries[appRun]!.sorted { $0.date < $1.date }) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.composedMessage)
                            HStack {
                                if let level = entry.level, selection.contains("Level") {
                                    Text(level.exportDescription)
                                }
                                if selection.contains("Date") {
                                    Text(entry.date.formatted())
                                }
                                if let subsystem = entry.subsystem, selection.contains("Subsystem") {
                                    Text(subsystem)
                                }
                                if let category = entry.category, selection.contains("Category") {
                                    Text(category)
                                }
                            }
                            .font(.caption)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, tokens: $currentTokens) { token in
            Text(token.name)
        }
        .toolbar {
            ToolbarSpacer(.flexible, placement: .bottomBar)
            if isFilterMenuShown {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        isFilterMenuShown.toggle()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
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
                List(items, id: \.self, selection: $selection) {
                    Text("\($0)")
                }
                .environment(\.editMode, .constant(EditMode.active))
            }

        }
        .animation(.easeInOut, value: isFilterMenuShown)
    }
}
