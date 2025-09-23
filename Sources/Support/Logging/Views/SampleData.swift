import SwiftData
import SwiftUI

struct SampleData: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: AppRun.self, configurations: config)
        
        let appRun = AppRun(appVersion: "1.0.0", operatingSystemVersion: "14.0.0", launchDate: Date(), device: "iPhone 12 Pro Max")
        let logEntries = [
            LogEntry(appRun: appRun, date: Date(), composedMessage: "Hello, world!", level: .info, category: "App", subsystem: "com.zuhlke.com"),
            LogEntry(appRun: appRun, date: Date(), composedMessage: "Bye, world!", level: .info, category: "App", subsystem: "com.zuhlke.com")
        ]
        
        let context = ModelContext(container)
        context.insert(appRun)
        context.insert(contentsOf: logEntries)
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
