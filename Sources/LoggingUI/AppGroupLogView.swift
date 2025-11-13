#if canImport(Darwin)

import Support
import SwiftData
import SwiftUI

/// A view that displays logs organized by app groups.
///
/// `AppGroupLogView` provides a hierarchical navigation interface for browsing logs
/// across multiple applications and their extensions (main app, widgets, etc.).
@available(iOS 26.0, macOS 26.0, *)
@available(watchOS, unavailable)
public struct AppGroupLogView: View {
    let logRetriever: LogRetriever

    /// Creates a new app group log view with the specified logging convention.
    ///
    /// - Parameter convention: The log storage convention used to locate and retrieve logs.
    public init(convention: LogStorageConvention) {
        // TODO: (P2) This force unwrap.
        logRetriever = try! LogRetriever(convention: convention)
    }
    
    public var body: some View {
        NavigationStack {
            List {
                ForEach(logRetriever.apps) { app in
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

#endif
