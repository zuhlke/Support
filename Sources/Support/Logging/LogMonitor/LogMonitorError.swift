#if canImport(Darwin)

import Foundation

/// Errors that can occur during LogMonitor operations.
enum LogMonitorError: LocalizedError {
    case logStoreCreationFailed(underlyingError: Error)
    case databaseOperationFailed(operation: String, underlyingError: Error)
    case logFetchFailed(underlyingError: Error)

    var errorDescription: String? {
        switch self {
        case .logStoreCreationFailed(let error):
            return "Failed to create log store: \(error.localizedDescription)"
        case .databaseOperationFailed(let operation, let error):
            return "Database \(operation) failed: \(error.localizedDescription)"
        case .logFetchFailed(let error):
            return "Failed to fetch logs: \(error.localizedDescription)"
        }
    }
}

#endif
