#if canImport(Darwin)

import OSLog

extension OSLogStore {
    
    /// Returns a sequence of log entries with timestamp after the provided date.
    public func entries(after date: Date) throws -> AnySequence<OSLogEntry> {
        // `OSLogStore` does not properly process `options` or `position`
        // so our implementation relies on the predicate
        // For more context, see: https://developer.apple.com/forums/thread/705868
        let predicate = NSPredicate(#Predicate<OSLogEntry> {
            $0.date > date
        })
        return try getEntries(matching: predicate)
    }
    
}
#endif
