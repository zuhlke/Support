#if canImport(Darwin)

import Foundation
import OSLog

protocol LogEntryProtocol {
    var composedMessage: String { get }
    var date: Date { get }
}

protocol LogStoreProtocol: Sendable {
    func entries(after date: Date) throws -> any Sequence<any LogEntryProtocol>
}



@available(macOS 10.15, *)
extension OSLogEntry: LogEntryProtocol {}

extension OSLogStore: LogStoreProtocol {
    func entries(after date: Date) throws -> any Sequence<any LogEntryProtocol> {
        let osLogEntries: AnySequence<OSLogEntry> = try entries(after: date)
        return osLogEntries.lazy.map { $0 as LogEntryProtocol }
    }
}

#endif
