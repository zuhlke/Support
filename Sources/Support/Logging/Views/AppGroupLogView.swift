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
    
    public var body: some View {
        NavigationStack {
            List(apps.flatMap(\.executables), id: \.bundleIdentifier) { executable in
                NavigationLink(executable.bundleIdentifier, value: executable)
            }
            .navigationTitle("Executables")
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
