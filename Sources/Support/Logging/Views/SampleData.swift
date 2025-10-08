#if os(iOS)

import SwiftData
import SwiftUI

struct SampleData: PreviewModifier {
    static func makeAppRun(
        context: ModelContext,
        launchDate: Date,
        category: String,
        subsystem: String
    ) {
        let appRun = AppRun(appVersion: "1.0.0", operatingSystemVersion: "14.0.0", launchDate: launchDate, device: "iPhone 12 Pro Max")
        let logEntries = [
            LogEntry(appRun: appRun, date: launchDate.advanced(by: 1 * 60), composedMessage: "This is an info level message", level: .info, category: category, subsystem: subsystem),
            LogEntry(appRun: appRun, date: launchDate.advanced(by: 2 * 60), composedMessage: "This is a debug level message", level: .debug, category: category, subsystem: subsystem),
            LogEntry(appRun: appRun, date: launchDate.advanced(by: 3 * 60), composedMessage: "This is a error level message", level: .error, category: category, subsystem: subsystem),
            LogEntry(appRun: appRun, date: launchDate.advanced(by: 4 * 60), composedMessage: "This is a fault level message", level: .fault, category: category, subsystem: subsystem),
            LogEntry(appRun: appRun, date: launchDate.advanced(by: 5 * 60), composedMessage: "This is a notice level message", level: .notice, category: category, subsystem: subsystem)
        ]
        
        context.insert(appRun)
        context.insert(contentsOf: logEntries)
    }
    
    static func makeSharedContext() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: AppRun.self, configurations: config)
        let context = ModelContext(container)
        let firstDate = Date()
        makeAppRun(context: context, launchDate: firstDate, category: "App", subsystem: "com.zuhlke.test")
        makeAppRun(context: context, launchDate: firstDate.advanced(by: 3600), category: "App", subsystem: "com.zuhlke.test")
        return container
    }
    
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {

    @available(iOS 26.0, *)
    @MainActor public static var sampleData: PreviewTrait<Preview.ViewTraits> {
        return .modifier(SampleData())
    }
}
#endif
