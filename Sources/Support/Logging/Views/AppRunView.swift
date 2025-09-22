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
    let items = ["Level", "Date", "Subsystem", "Category"]
    @State var selection = Set<String>(["Level", "Date", "Subsystem", "Category"])
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
    
    var logList: some View {
        List {
            ForEach(groupedEntries.keys.sorted { $0.launchDate > $1.launchDate }, id: \.self) { appRun in
                Section(appRun.launchDate.formatted()) {
                    ForEach(groupedEntries[appRun]!.sorted { $0.date < $1.date }) { entry in
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
                                    Text(entry.date.formatted()) // probably no highlighting for dates
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
            }
        }
    }
    
    var body: some View {
        logList
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


extension String {
    func highlighted(matching queries: [String], highlightColor: Color = .yellow.opacity(0.4)) -> AttributedString {
        var attributed = AttributedString(self)
        let lowerSelf = self.lowercased()
        
        for query in queries where !query.isEmpty {
            let lowerQuery = query.lowercased()
            var searchRange = lowerSelf.startIndex..<lowerSelf.endIndex
            
            while let range = lowerSelf.range(of: lowerQuery, options: .caseInsensitive, range: searchRange) {
                if let attrRange = Range(range, in: attributed) {
                    attributed[attrRange].backgroundColor = UIColor(highlightColor)
                }
                searchRange = range.upperBound..<lowerSelf.endIndex
            }
        }
        
        return attributed
    }
}

struct SampleData: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: AppRun.self, configurations: config)
        
        let appRun = AppRun(appVersion: "1.0.0", operatingSystemVersion: "14.0.0", launchDate: Date(), device: "iPhone 12 Pro Max")
        let logEntries = [
            LogEntry(appRun: appRun, date: Date(), composedMessage: "Hello, world!", level: .info, category: "App", subsystem: "com.zuhlke.com"),
            LogEntry(appRun: appRun, date: Date(), composedMessage: "Bye, world!", level: .info, category: "App", subsystem: "com.zuhlke.com")
        ]
        
        let context = ModelContext(container)
        context.insert(appRun)
        context.insert(contentsOf: logEntries)
        return container
    }
    
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {

    @available(iOS 26.0, *)
    @MainActor public static var sampleData: PreviewTrait<Preview.ViewTraits> {
        return .modifier(SampleData())
    }
}


@available(iOS 26.0, *)
#Preview(traits: .sampleData) {
    AppRunView()
}

#endif
