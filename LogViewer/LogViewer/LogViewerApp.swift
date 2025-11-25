import LoggingUI
import Support
import SwiftData
import SwiftUI

@main
struct LogViewerApp: App {
    var body: some Scene {
        WindowGroup {
#if os(macOS)
            NavigationStack {
                LogImportView()
            }
#else
            LogBrowserStack(
                convention: .commonAppGroup(
                    identifier: "group.com.zuhlke.diagnostics"
                )
            )
#endif
        }
    }
}
