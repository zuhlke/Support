#if os(iOS)
#if canImport(SwiftUI)

import Support
import SwiftData
import SwiftUI

@available(iOS 26.0, *)
@available(macOS, unavailable)
public struct AppGroupLogView: View {
    let logRetriever: LogRetriever
    
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
#endif
