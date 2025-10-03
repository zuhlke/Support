#if os(iOS)
#if canImport(SwiftUI)

import SwiftUI
import SwiftData
@preconcurrency import Combine

// TODO: P3 - Review Unchecked Sendable and if we can make it safe
@Observable
class AppGroupLogViewModel: @unchecked Sendable {
    let logRetriever: LogRetriever

    var apps: [AppLogContainer] = []

    init(convention: LogStorageConvention) {
        let logRetriever = try! LogRetriever(convention: convention)
        self.logRetriever = logRetriever
        Task {
            do {
                for try await value in logRetriever.appsStream {
                    self.apps = value
                }
            } catch {
                // TODO: P3 - Handle error here
            }
        }
    }
}

@available(iOS 26.0, *)
@available(macOS, unavailable)
public struct AppGroupLogView: View {
    let viewModel: AppGroupLogViewModel
    
    public init(convention: LogStorageConvention) {
        self.viewModel = AppGroupLogViewModel(convention: convention)
    }
    
    public var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.apps) { app in
                    Section(app.displayName) {
                        ForEach(app.executables) { executable in
                            NavigationLink(value: executable) {
                                let systemImage = switch executable.packageType {
                                case .mainApp: "app"
                                case .extension(extensionPointIdentifier: "com.apple.intents-service"),
                                    .extension(extensionPointIdentifier: "com.apple.intents-ui-service"): "siri"
                                case .extension(extensionPointIdentifier: "com.apple.widgetkit-extension"): "widget.small"
                                case .extension: "puzzlepiece.extension"
                                }

                                Label(executable.displayName, systemImage: systemImage)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Apps")
            .navigationDestination(for: ExecutableLogContainer.self) { executable in
                AppRunView()
                    .modelContainer(try! ModelContainer(from: executable))
            }
        }
    }
}

private extension ModelContainer {
    convenience init(from executable: ExecutableLogContainer) throws {
        try self.init(for: AppRun.self, configurations: ModelConfiguration(url: executable.url))
    }
}

#endif
#endif
