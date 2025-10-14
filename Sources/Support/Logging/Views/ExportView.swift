#if canImport(SwiftUI)
import SwiftUI

struct ExportView: View {
    var file: URL
    
    init(logEntry: LogEntry) {
        let jsonData = try? JSONEncoder().encode(logEntry.snapshot)
        file = FileManager.default.temporaryDirectory.appendingPathComponent("logEntry.json")
        if let data = jsonData {
            try? data.write(to: file, options: .atomic)
        }
    }
    
    init(logEntries: [LogEntry]) {
        let jsonData = try? JSONEncoder().encode(logEntries.map(\.snapshot))
        file = FileManager.default.temporaryDirectory.appendingPathComponent("logEntries.json")
        if let data = jsonData {
            try? data.write(to: file, options: .atomic)
        }
    }
    
    var body: some View {
        ShareLink(item: file, preview: SharePreview("Log Entries", image: Image(systemName: "text.document"))) {
            Image(systemName: "square.and.arrow.up")
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Export")
            }
        }
    }
}
#endif
