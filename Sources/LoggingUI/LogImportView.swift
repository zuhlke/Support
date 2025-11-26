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
@MainActor
public struct LogImportView: View {
    private let modelContainer: ModelContainer

    @State private var hasImportedLogs = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private nonisolated static let decoder: JSONDecoder = {
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
            if isLoading {
                loadingView
            } else if hasImportedLogs {
                AppRunView()
                    .modelContainer(modelContainer)
            } else {
                emptyStateView
            }
        }
        .navigationTitle("Log Viewer")
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            guard let provider = providers.first else { return false }
            Task { await handleFileDrop(provider: provider) }
            return true
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

    /// Loading view shown while importing logs
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Importing Logs...")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Please wait while we process your log file")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helper Functions

    private func handleFileDrop(provider: NSItemProvider) async  {
        do {
            let item = try await provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier)
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }
            
            guard url.pathExtension.lowercased() == "json" else {
                errorMessage = "Please drop a valid log file"
                return
            }
            
            isLoading = true
            await importLogs(from: url)
        } catch {
            errorMessage = "Something went wrong - \(error.localizedDescription)"
        }
    }

    @concurrent
    private func importLogs(from url: URL) async {
        // Perform heavy work on background queue
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

            // Update UI
            await MainActor.run {
                isLoading = false
                hasImportedLogs = true
            }
        } catch {
            // Update UI with error
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to import logs: \(error.localizedDescription)"
            }
        }
    }

    /// Converts a string log level to OSLogEntryLog.Level
    /// - Parameter levelString: The log level as a string
    /// - Returns: The corresponding OSLogEntryLog.Level or nil
    private nonisolated func convertLevel(from levelString: String?) -> OSLogEntryLog.Level? {
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
