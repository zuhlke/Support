import LoggingUI
import Support
import SwiftData
import SwiftUI

@main
struct LogViewerApp: App {
    var body: some Scene {
        WindowGroup {
            AppGroupLogView(convention: .commonAppGroup(identifier: "group.com.zuhlke.diagnostics"))
        }
    }
}
