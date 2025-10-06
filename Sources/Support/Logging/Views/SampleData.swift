#if os(iOS)

import SwiftData
import SwiftUI

struct SampleData: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: AppRun.self, configurations: config)
        
        let appRun = AppRun(appVersion: "1.0.0", operatingSystemVersion: "14.0.0", launchDate: Date(), device: "iPhone 12 Pro Max")
        let logEntries = [
            LogEntry(appRun: appRun, date: Date(), composedMessage: "This is an info level message", level: .info, category: "App", subsystem: "com.zuhlke.test"),
            LogEntry(appRun: appRun, date: Date(), composedMessage: "This is a debug level message", level: .debug, category: "App", subsystem: "com.zuhlke.test"),
            LogEntry(appRun: appRun, date: Date(), composedMessage: "This is a error level message", level: .error, category: "App", subsystem: "com.zuhlke.test"),
            LogEntry(appRun: appRun, date: Date(), composedMessage: "This is a fault level message", level: .fault, category: "App", subsystem: "com.zuhlke.test"),
            LogEntry(appRun: appRun, date: Date(), composedMessage: "This is a notice level message", level: .notice, category: "App", subsystem: "com.zuhlke.test")
        ]
        
        let appRun2 = AppRun(appVersion: "1.0.0", operatingSystemVersion: "14.0.0", launchDate: Date().advanced(by: 3600), device: "iPhone 12 Pro Max")
        let logEntries2 = [
            LogEntry(appRun: appRun2, date: Date(), composedMessage: "This is an info level message", level: .info, category: "App", subsystem: "com.zuhlke.test"),
            LogEntry(appRun: appRun2, date: Date(), composedMessage: "This is a debug level message", level: .debug, category: "App", subsystem: "com.zuhlke.test"),
            LogEntry(appRun: appRun2, date: Date(), composedMessage: "This is a error level message", level: .error, category: "App", subsystem: "com.zuhlke.test"),
            LogEntry(appRun: appRun2, date: Date(), composedMessage: "This is a fault level message", level: .fault, category: "App", subsystem: "com.zuhlke.test"),
            LogEntry(appRun: appRun2, date: Date(), composedMessage: "This is a notice level message", level: .notice, category: "App", subsystem: "com.zuhlke.test")
        ]
        
        let context = ModelContext(container)
        context.insert(appRun)
        context.insert(appRun2)
        context.insert(contentsOf: logEntries)
        context.insert(contentsOf: logEntries2)
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
