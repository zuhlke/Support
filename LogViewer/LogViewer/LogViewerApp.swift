import SwiftUI
import SwiftData
import LoggingUI
import Support

@main
struct LogViewerApp: App {
    var body: some Scene {
        WindowGroup {
            AppGroupLogView(convention: .commonAppGroup(identifier: "group.com.zuhlke.diagnostics"))
        }
    }
}
