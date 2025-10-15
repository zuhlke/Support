#if canImport(Darwin)

import Foundation
import OSLog

class FileWatcher: AsyncSequence {
    private static let logger = Logger(subsystem: "com.zuhlke.Support", category: "FileWatcher")
    
    enum Event {
        case changed
    }
    
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(url: url)
    }
}

extension FileWatcher {
    class AsyncIterator: AsyncIteratorProtocol {
        private let filePresenter: FilePresenter

        init(url: URL) {
            FileWatcher.logger.trace("Initializing FileWatcher Iterator at url: \(url)")
            filePresenter = FilePresenter(url: url)
            NSFileCoordinator.addFilePresenter(filePresenter)

            // We call this to ensure that the NSFileCoordinator has registered the presenter
            // Any changes to this file will notify the presenter after this is called.
            NSFileCoordinator(filePresenter: filePresenter).coordinate(
                readingItemAt: filePresenter.presentedItemURL!,
                error: nil,
                byAccessor: { _ in }
            )
        }

        func next() async -> FileWatcher.Event? {
            FileWatcher.logger.trace("Awaiting change at url: \(self.filePresenter.presentedItemURL!)")
            return await withTaskCancellationHandler {
                if Task.isCancelled { return nil }
                return await withCheckedContinuation { continuation in
                    filePresenter.setContinuation(continuation: continuation)
                }
            } onCancel: { [filePresenter] in
                filePresenter.cancelContinuation()
            }
        }

        deinit {
            FileWatcher.logger.trace("Deinitializing FileWatcher Iterator at url: \(self.filePresenter.presentedItemURL!)")
            NSFileCoordinator.removeFilePresenter(filePresenter)
        }
    }
}

extension FileWatcher {
    private final class FilePresenter: NSObject, NSFilePresenter, @unchecked Sendable {
        private var continuation: CheckedContinuation<Event?, Never>?

        let presentedItemURL: URL?
        let presentedItemOperationQueue = OperationQueue()

        init(url: URL) {
            self.presentedItemURL = url
            super.init()
            presentedItemOperationQueue.maxConcurrentOperationCount = 1
        }

        func setContinuation(continuation: CheckedContinuation<Event?, Never>) {
            presentedItemOperationQueue.addOperation {
                self.continuation = continuation
            }
        }

        func presentedItemDidChange() {
            FileWatcher.logger.trace("Presented item did change at url: \(self.presentedItemURL!)")
            continuation?.resume(returning: .changed)
            continuation = nil
        }
        
        func cancelContinuation() {
            presentedItemOperationQueue.addOperation {
                self.continuation?.resume(returning: nil)
                self.continuation = nil
            }
        }
    }
}

#endif
