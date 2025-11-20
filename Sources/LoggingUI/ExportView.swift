#if canImport(Darwin)

import Support
import SwiftUI

struct ExportView: View {
    private let shareData: Data
    private let fileName: String

    init(groupedEntries: [AppRun: [LogEntry]]) {
        let appRunSnapshots = groupedEntries.map { key, value in
            ExportData(
                appRun: key.snapshot.info,
                logEntries: value.map(\.snapshot)
            )
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let jsonData = try? encoder.encode(appRunSnapshots)
        shareData = jsonData ?? .init()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        fileName = "app_runs_\(timestamp).json"
    }

    var body: some View {
        ShareLink(
            item: JSONFile(data: shareData, filename: fileName),
            preview: SharePreview("App Runs", image: Image(systemName: "doc.text"))
        ) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Export")
            }
        }
    }
}

private struct JSONFile: Transferable {
    let data: Data
    let filename: String

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { file in
            file.data
        }
        .suggestedFileName { file in
            file.filename
        }
    }
}

private struct ExportData: Codable {
    let appRun: AppRun.Snapshot.Info
    let logEntries: [LogEntry.Snapshot]
}

#endif
