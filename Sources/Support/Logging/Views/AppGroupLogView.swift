import SwiftUI
import SwiftData

@available(iOS 26.0, *)
@available(macOS, unavailable)
public struct AppGroupLogView: View {
    var convention: LogStorageConvention
    
    public init(convention: LogStorageConvention) {
        self.convention = convention
    }
    
    var modalContainers: [String: ModelContainer] {
        let logRetriever = try! LogRetriever(convention: convention)
        let executables = try! logRetriever.apps.flatMap(\.executables)
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
