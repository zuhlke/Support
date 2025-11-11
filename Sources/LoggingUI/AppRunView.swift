#if canImport(Darwin)

import Support
import SwiftData
import SwiftUI

@available(iOS 26.0, macOS 26.0, *)
struct AppRunView: View {
    @Query(
        filter: #Predicate<LogEntry> { entry in
            entry.subsystem != nil && entry.subsystem != "" && !(entry.subsystem?.contains("com.apple.") ?? false)
        },
        sort: \.date,
        order: .reverse,
    ) var logEntries: [LogEntry]
    
    @State var isShowingMetadata = Set<Metadata>(Metadata.allCases)
    @State var shouldShowExpandedMessages = false
    @State private var searchText = ""
    @State private var tokens: [SearchToken] = []
    @State private var filteredEntries: [LogEntry] = []
    @State private var groupedEntries: [AppRun: [LogEntry]] = [:]
    
    func filterEntries() {
        filteredEntries = logEntries.filter(searchText: searchText, tokens: tokens)
        groupedEntries = Dictionary(grouping: filteredEntries) { $0.appRun }
    }
    
    @ViewBuilder
    func similarItem(entry: LogEntry, scope: SearchScope) -> some View {
        if let text = entry.scope(scope) {
            Button {
                if !tokens.contains(where: { token in
                    token.text == text && token.scope == scope
                }) {
                    tokens.append(SearchToken(text, in: scope))
                }
            } label: {
                HStack {
                    Image(systemName: scope.image)
                    Text(text)
                }
            }
        } else {
            EmptyView()
        }
    }
    
    func contextMenu(for entry: LogEntry) -> some View {
        VStack {
            #if os(iOS)
                Button {
                    UIPasteboard.general.string = entry.composedMessage
                } label: {
                    Image(systemName: "document.on.document")
                    Text("Copy")
                }
            #endif
            ExportView(logEntry: entry)
            Menu {
                similarItem(entry: entry, scope: .message)
                similarItem(entry: entry, scope: .level)
                similarItem(entry: entry, scope: .subsystem)
                similarItem(entry: entry, scope: .category)
            } label: {
                Image(systemName: "eye")
                Text("Show Similar Items")
            }
        }
    }
    
    func appRunHeader(appRun: AppRun) -> some View {
        HStack(alignment: .center) {
            Text(appRun.launchDate.formatted())
                .font(.headline)
            Spacer()
            Menu {
                ExportView(logEntries: groupedEntries[appRun]!)
                Section {
                    Text("App version: \(appRun.appVersion)")
                    Text("Operating System Version: \(appRun.operatingSystemVersion)")
                    Text("Launch Date: \(appRun.launchDate.formatted())")
                    Text("Device: \(appRun.device)")
                }
            } label: {
                Image(systemName: "info.circle")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect()
    }
    
    var appRuns: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(groupedEntries.keys.sorted(by: { $0.launchDate < $1.launchDate }), id: \.self) { appRun in
                    Section {
                        ForEach(groupedEntries[appRun]!.sorted(by: { $0.date < $1.date })) { entry in
                            LogEntryView(entry: entry, searchText: searchText, tokens: tokens, isShowingMetadata: isShowingMetadata, shouldShowExpandedMessages: shouldShowExpandedMessages)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(entry.background)
                                .overlay(Divider().padding(.horizontal, 16), alignment: .bottom)
                                .contextMenu { contextMenu(for: entry) }
                        }
                    } header: {
                        appRunHeader(appRun: appRun)
                    }
                }
            }
        }
        .defaultScrollAnchor(.bottom)
    }

    func suggestionText(for scope: SearchScope) -> some View {
        HStack {
            Text("\(Image(systemName: scope.image))").bold().foregroundStyle(.blue).frame(width: 30)
            Text("\(scope.rawValue.capitalized) contains: ").foregroundStyle(.secondary) + Text("\(searchText)")
        }
        .tint(.primary)
        .searchCompletion(SearchToken(searchText, in: scope))
    }
    
    var searchableAppRuns: some View {
        appRuns
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
                        ForEach(filteredEntries, id: \.self) { entry in
                            LogEntryView(entry: entry, searchText: searchText, tokens: tokens, isShowingMetadata: isShowingMetadata, shouldShowExpandedMessages: shouldShowExpandedMessages)
                                .listRowBackground(entry.background)
                                .contextMenu { contextMenu(for: entry) }
                        }
                    }
                }
            }
    }
    
    var menu: some View {
        Menu {
            Section {
                ExportView(logEntries: filteredEntries)
            }
            ForEach(Metadata.allCases, id: \.self) { metadata in
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
            Section {
                Toggle(isOn: $shouldShowExpandedMessages) {
                    HStack {
                        Image(systemName: "rectangle.expand.vertical")
                        Text("Expand log messages")
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
        }
    }
    
    var body: some View {
        searchableAppRuns
            .onChange(of: [logEntries.description, tokens.description, searchText], initial: true) {
                filterEntries()
            }
            #if os(iOS)
            .toolbar {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarItem(placement: .topBarTrailing) {
                    menu
                }
            }
            #endif
    }
}

@available(iOS 26.0, macOS 26.0, watchOS 11.0, *)
#Preview(traits: .sampleData) {
    NavigationStack {
        AppRunView()
    }
}

#endif
