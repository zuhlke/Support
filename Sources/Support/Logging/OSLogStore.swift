import Foundation

public protocol OSLogEntryProtocol {
    var composedMessage: String { get }
    var date: Date { get }
}

public protocol OSLogStoreProtocol {
    func entries(after date: Date) throws -> AnySequence<OSLogEntryProtocol>
}

#if canImport(OSLog)

import OSLog

@available(macOS 10.15, *)
extension OSLogEntry: OSLogEntryProtocol {}

extension OSLogStore: OSLogStoreProtocol {
    
    /// Returns a sequence of log entries with timestamp after the provided date.
    public func entries(after date: Date) throws -> AnySequence<OSLogEntryProtocol> {
        // `OSLogStore` does not properly process `options` or `position`
        // so our implementation relies on the predicate
        // For more context, see: https://developer.apple.com/forums/thread/705868
        let predicate = NSPredicate(#Predicate<OSLogEntry> {
            $0.date > date
        })

        let entries = try getEntries(matching: predicate)
        return AnySequence(entries.map { $0 as OSLogEntryProtocol })
    }
    
}

#endif
