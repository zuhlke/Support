
#if canImport(OSLog)
import OSLog

extension OSLogStore {
    
    /// Returns a sequence of log entries with timestamp after the provided date.
    public func entries(after date: Date) throws -> AnySequence<OSLogEntry> {
        let predicate = NSPredicate(#Predicate<OSLogEntry> {
            $0.date > date
        })
        return try getEntries(matching: predicate)
    }
    
}
#endif
