#if os(iOS)
#if canImport(SwiftUI)

import SwiftUI
import SwiftData

@available(iOS 26.0, *)
@available(macOS, unavailable)
public struct AppGroupLogView: View {
    
    // TODO: P2 – Dynamically update list of apps as they are detected
    // This first needs a change in `LogRetriever` to publish this data.
    var apps: [AppLogContainer]
    
    public init(convention: LogStorageConvention) {
        let logRetriever = try! LogRetriever(convention: convention)
        apps = try! logRetriever.apps
            .sorted(using: KeyPathComparator(\.bundleIdentifier))
    }
    
    var modalContainers: [String: ModelContainer] {
        let executables = try! apps.flatMap(\.executables)
        return Dictionary(uniqueKeysWithValues: executables.map { executable in
            let modalContainer = try! ModelContainer(for: AppRun.self, configurations: ModelConfiguration(url: executable.url))
            return (executable.bundleIdentifier, modalContainer)
        })
    }
    
    public var body: some View {
        NavigationStack {
            List(modalContainers.keys.sorted(), id: \.self) { bundleIdentifier in
                NavigationLink(bundleIdentifier, value: bundleIdentifier)
            }
            .navigationTitle("Executables")
            .navigationDestination(for: String.self) { bundleIdentifier in
                AppRunView()
                    .modelContainer(modalContainers[bundleIdentifier]!)
            }
        }
    }
}

#endif
#endif
