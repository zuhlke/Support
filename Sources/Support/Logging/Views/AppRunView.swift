import SwiftUI
import SwiftData
import Support

struct AppRunView: View {
    @Query(sort: \LogEntry.date, order: .reverse) var logEntries: [LogEntry]
    
    @State var isFilterMenuShown: Bool = false
    let items = ["Level", "Date", "Subsystem", "Category"]
    @State var selection = Set<String>(["Level", "Date", "Subsystem", "Category"])

    var groupedEntries: [AppRun: [LogEntry]] {
        Dictionary(grouping: logEntries.filter {
            !($0.subsystem?.hasPrefix("com.apple.") ?? false) }
        ) { $0.appRun }
    }
    
    var body: some View {
        List {
            ForEach(groupedEntries.keys.sorted { $0.launchDate > $1.launchDate }, id: \.self) { appRun in
                Section(appRun.launchDate.formatted()) {
                    ForEach(groupedEntries[appRun]!) { entry in
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
        .toolbar {
            Button {
                isFilterMenuShown = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
            }
            .popover(isPresented: $isFilterMenuShown) {
                List(items, id: \.self, selection: $selection) {
                    Text("\($0)")
                }
                .environment(\.editMode, .constant(EditMode.active))
                .presentationCompactAdaptation(.popover)
                .frame(minWidth: 200, minHeight: 275)
            }
        }
    }
}
