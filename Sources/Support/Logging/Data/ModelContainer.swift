#if canImport(Darwin)

import SwiftData

public extension ModelContainer {
    convenience init(from executable: ExecutableLogContainer) throws {
        try self.init(
            for: AppRun.self,
            configurations: ModelConfiguration(
                url: executable.url,
            ),
        )
    }
}

#endif
