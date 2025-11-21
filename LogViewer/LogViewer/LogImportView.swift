#if os(macOS)
import AppKit
import LoggingUI
import OSLog
import Support
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// macOS view for importing and displaying JSON logs exported from iOS
struct LogImportView: View {
    @State private var modelContainer: ModelContainer?
    @State private var hasImportedLogs = false
    @State private var errorMessage: String?

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({
            let string = try $0.singleValueContainer().decode(String.self)
            do {
                return try .init(string, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true))
            } catch {
                return try .init(string, strategy: .iso8601)
            }
        })
        return decoder
    }()

    init() {
        // Create an in-memory SwiftData container for imported logs
        let schema = Schema([AppRun.self, LogEntry.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: schema, configurations: configuration)
            _modelContainer = State(initialValue: container)
        } catch {
            print("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some View {
        Group {
            if hasImportedLogs, let container = modelContainer {
                // Use AppRunView directly - it has all the features we need
                AppRunView()
                    .modelContainer(container)
            } else {
                emptyStateView
            }
        }
        .navigationTitle("Log Viewer")
        .alert("Import Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
    }

    // MARK: - View Components

    /// Empty state view shown when no logs are imported
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Logs Imported")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Import a JSON log file to view entries")
                .font(.body)
                .foregroundStyle(.secondary)

            Button {
                // Show file picker
                let panel = NSOpenPanel()
                panel.allowedContentTypes = [.json]
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.canChooseFiles = true

                if panel.runModal() == .OK, let url = panel.url {
                    importLogs(from: url)
                }
            } label: {
                Label("Import Logs", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helper Functions

    /// Imports logs from the specified JSON file and converts them to SwiftData models
    /// - Parameter url: URL of the JSON file to import
    private func importLogs(from url: URL) {
        guard let container = modelContainer else {
            errorMessage = "Model container not initialized"
            return
        }

        do {
            // Read the file data
            let data = try Data(contentsOf: url)

            // Decode the JSON array of AppRun snapshots
            let appRunSnapshots = try LogImportView.decoder.decode([AppRun.Snapshot].self, from: data)

            // Create a new context
            let context = ModelContext(container)

            // Import each app run with its log entries
            for snapshot in appRunSnapshots {
                // Create an AppRun from the snapshot info
                let appRun = AppRun(
                    appVersion: snapshot.info.appVersion,
                    operatingSystemVersion: snapshot.info.operatingSystemVersion,
                    launchDate: snapshot.info.launchDate,
                    device: snapshot.info.device
                )
                context.insert(appRun)

                // Convert each log entry snapshot to LogEntry and insert into context
                for logEntrySnapshot in snapshot.logEntries {
                    let level = convertLevel(from: logEntrySnapshot.level)
                    let entry = LogEntry(
                        appRun: appRun,
                        date: logEntrySnapshot.date,
                        composedMessage: logEntrySnapshot.composedMessage,
                        level: level,
                        category: logEntrySnapshot.category,
                        subsystem: logEntrySnapshot.subsystem
                    )
                    context.insert(entry)
                }
            }

            // Save the context
            try context.save()

            // Show the AppRunView with imported logs
            hasImportedLogs = true

        } catch {
            errorMessage = "Failed to import logs: \(error.localizedDescription)"
        }
    }

    /// Converts a string log level to OSLogEntryLog.Level
    /// - Parameter levelString: The log level as a string
    /// - Returns: The corresponding OSLogEntryLog.Level or nil
    private func convertLevel(from levelString: String?) -> OSLogEntryLog.Level? {
        guard let levelString = levelString?.lowercased() else { return nil }

        switch levelString {
        case "debug": return .debug
        case "info": return .info
        case "notice": return .notice
        case "error": return .error
        case "fault": return .fault
        default: return nil
        }
    }
}

#Preview {
    NavigationStack {
        LogImportView()
    }
}
#endif
