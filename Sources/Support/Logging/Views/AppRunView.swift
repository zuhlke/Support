#if canImport(SwiftUI)

import SwiftUI
import SwiftData

enum LogToken: Identifiable, Hashable {
    case level(String)
    case subsystem(String)
    case category(String)
    
    var id: String {
        switch self {
        case .level(let value):
            return value
        case .category(let value):
            return value
        case .subsystem(let value):
            return value
        }
    }
    
    var displayName: String {
        switch self {
        case .level(let value):
            return "Level: \(value)"
        case .category(let value):
            return "Category: \(value)"
        case .subsystem(let value):
            return "Subsystem: \(value)"
        }
    }
}

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
    @State private var logTokens: [LogToken] = [.level("Notice")]
    
    var levels: [String] {
        logEntries.compactMap { logEntry in
            logEntry.level?.exportDescription
        }
    }
    
    var subsystems: [String] {
        logEntries.compactMap { logEntry in
            logEntry.subsystem
        }
    }
    
    var categories: [String] {
        logEntries.compactMap { logEntry in
            logEntry.category
        }
    }
    
    var possibleTokens: [Token] {
        (levels + subsystems + categories).map(Token.init)
    }
    
    @State var currentTokens = [Token]()
    
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
    
    var logList: some View {
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
    }
    
    var body: some View {
        logList
            .searchable(text: $searchText, tokens: $currentTokens) { token in
            Text(token.name)
        }
        .onChange(of: searchText) {
            if let token = searchText.endWithToken(possibleTokens) {
                if !currentTokens.contains(where: { $0.name == token.name }) {
                    searchText.removeLast(token.name.count)
                    currentTokens.append(token)
                }
            }
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
    func endWithToken(_ types: [Token]) -> Token? {
        let selfLowercased = self.lowercased()
        for type in types {
            if selfLowercased.hasSuffix(type.name.lowercased()) {
                return type
            }
        }
        return nil
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
