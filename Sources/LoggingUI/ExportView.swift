#if canImport(Darwin)

import Support
import SwiftUI

struct ExportView: View {
    private let shareData: Data

    init(groupedEntries: [AppRun: [LogEntry]]) {
        let appRunSnapshots = groupedEntries.map { key, value in
            AppRunExportSnapshot(
                info: key.snapshot.info,
                logEntries: value.map(\.snapshot)
            )
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .custom({ date, encoder in
            let dateString = date.ISO8601Format(Date.ISO8601FormatStyle(includingFractionalSeconds: true))
            var container = encoder.singleValueContainer()
            try container.encode(dateString)
        })

        let jsonData = try? encoder.encode(appRunSnapshots)
        shareData = jsonData ?? .init()
    }

    var body: some View {
        ShareLink(
            item: JSONFile(data: shareData),
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
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return dateFormatter
    }()

    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { file in
            file.data
        }
        .suggestedFileName { file in
            let timestamp = Self.dateFormatter.string(from: Date())
            return "app_runs_\(timestamp).json"
        }
    }
}

private struct AppRunExportSnapshot: Codable {
    let info: AppRun.Snapshot.Info
    let logEntries: [LogEntry.Snapshot]
}

#endif
