#if os(macOS)
import OSLog
import Support
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// A view that enables importing and viewing log files on macOS.
///
/// `LogImportView` provides a drag-and-drop interface for importing log files.
@available(macOS 15.0, *)
public struct LogImportView: View {
    private let modelContainer: ModelContainer

    @State private var hasImportedLogs = false
    @State private var errorMessage: String?

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({
            let string = try $0.singleValueContainer().decode(String.self)
            return try .init(string, strategy: Date.ISO8601FormatStyle(
                includingFractionalSeconds: true
            ))
        })
        return decoder
    }()

    /// Creates a new log import view.
    public init() {
        // Create an in-memory SwiftData container for imported logs
        let schema = Schema([AppRun.self, LogEntry.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        self.modelContainer = try! ModelContainer(for: schema, configurations: configuration)
    }

    public var body: some View {
        Group {
            if hasImportedLogs {
                AppRunView()
                    .modelContainer(modelContainer)
            } else {
                emptyStateView
            }
        }
        .navigationTitle("Log Viewer")
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            handleFileDrop(providers: providers)
        }
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
            Image(systemName: "arrow.down.doc")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Drop JSON Log File")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Drag and drop a JSON log file anywhere to view entries")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helper Functions

    private func handleFileDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
            // Get the URL from the dropped item
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }

            // Check if it's a JSON file
            guard url.pathExtension.lowercased() == "json" else {
                DispatchQueue.main.async {
                    errorMessage = "Please drop a JSON file"
                }
                return
            }

            // Import the logs on the main thread, replacing any existing logs
            DispatchQueue.main.async {
                importLogs(from: url)
            }
        }

        return true
    }

    private func importLogs(from url: URL) {
        do {
            // Read the file data
            let data = try Data(contentsOf: url)

            // Decode the JSON array of AppRun snapshots
            let appRunSnapshots = try LogImportView.decoder.decode([AppRun.Snapshot].self, from: data)

            // Create a new context
            let context = ModelContext(modelContainer)

            // Clear existing data by deleting all AppRuns and LogEntries
            try context.delete(model: AppRun.self)
            try context.delete(model: LogEntry.self)

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
#endif
