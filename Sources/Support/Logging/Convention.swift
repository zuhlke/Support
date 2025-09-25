#if canImport(SwiftData)

import Foundation

public struct LogStorageConvention: Sendable {
    public enum BaseStorageLocation: Sendable {
        case appGroup(identifier: String)
    }

    /// Indicates where on the system the logs should be stored
    var baseStorageLocation: BaseStorageLocation
    
    /// Where would logs following this convention be stored
    var basePathComponents: [String]

    public init(baseStorageLocation: BaseStorageLocation, basePathComponents: [String]) {
        self.baseStorageLocation = baseStorageLocation
        self.basePathComponents = basePathComponents
    }
}

extension LogStorageConvention {
    /// A convention that uses app groups, allowing all apps/executables using the same developer team to be stored and browsed with the same convention.
    ///
    /// - note: An executable must have the associated app group entitlement to read or write logs using this convention.
    ///
    /// - Parameter identifier: The app group identifier.
    public static func commonAppGroup(identifier: String) -> LogStorageConvention {
        LogStorageConvention(
            baseStorageLocation: .appGroup(identifier: identifier),
            basePathComponents: []
        )
    }
}

extension LogStorageConvention {
    var manifestDirectory: String {
        "Manifests"
    }
    
    var logsDirectory: String {
        "Logs"
    }
    
    var logsFileExtension: String {
        "logs"
    }
}

extension FileManager {
    
    func url(for storageLocation: LogStorageConvention.BaseStorageLocation) throws -> URL {
        switch storageLocation {
        case .appGroup(let identifier):
            guard let appGroupFolder = containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
                throw UndefinedAppGroup(identifier: identifier)
            }
            return appGroupFolder
        }
    }
    
}

extension URL {
    
    func appending(components: [String]) -> URL {
        components.reduce(self) { $0.appending(component: $1, directoryHint: .isDirectory) }
    }
    
}

private struct UndefinedAppGroup: Error, Sendable {
    var identifier: String
}

#endif
