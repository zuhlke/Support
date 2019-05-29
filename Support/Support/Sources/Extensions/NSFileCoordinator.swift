import Foundation

extension NSFileCoordinator {
    
    private enum Errors: Error {
        case unknown
    }
    
    func coordinate<Output>(readingItemAt url: URL, options: NSFileCoordinator.ReadingOptions = [], byAccessor reader: @escaping (URL) throws -> Output) throws -> Output {
        var output: Output?
        var nsError: NSError?
        var err: Error?
        coordinate(readingItemAt: url, options: options, error: &nsError) { url in
            do {
                output = try reader(url)
            }
            catch {
                err = error
            }
        }
        
        guard let out = output else {
            throw err ?? nsError ?? Errors.unknown
        }
        
        return out
    }
    
    func coordinate(writingItemAt url: URL, options: NSFileCoordinator.WritingOptions = [], byAccessor writer: (URL) throws -> Void) throws {
        var nsError: NSError?
        var err: Error?
        
        coordinate(writingItemAt: url, options: options, error: &nsError) { url in
            do {
                try writer(url)
            } catch {
                err = error
            }
        }
        
        if let error = err ?? nsError {
            throw error
        }
    }
    
}
