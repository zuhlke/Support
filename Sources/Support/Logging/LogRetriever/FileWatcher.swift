#if canImport(Darwin)

import Foundation

class FileWatcher {
    private var presenter: FilePresenter

    init(url: URL, onChange: @escaping () -> Void) {
        self.presenter = FilePresenter(url: url) {
            onChange()
        }
    }

    func startWatching() async {
        await presenter.startWatching()
    }

    func stopWatching() {
        presenter.stopWatching()
    }

    deinit {
        stopWatching()
    }
}

extension FileWatcher {
    static func asynStream(url: URL) async -> AsyncStream<Void> {
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self)
        let watcher = FileWatcher(url: url) {
            continuation.yield()
        }

        await watcher.startWatching()

        return stream
    }
}

private class FilePresenter: NSObject, NSFilePresenter {
    let presentedItemURL: URL?
    let presentedItemOperationQueue = OperationQueue()
    private let onChange: () -> Void

    init(url: URL, onChange: @escaping () -> Void) {
        self.presentedItemURL = url
        self.onChange = onChange
        super.init()
        presentedItemOperationQueue.maxConcurrentOperationCount = 1
    }

    func startWatching() async {
        NSFileCoordinator.addFilePresenter(self)
        await withCheckedContinuation { continuation in
            NSFileCoordinator(filePresenter: self).coordinate(
                readingItemAt: presentedItemURL!,
                error: nil,
                byAccessor: { _ in }
            )
            continuation.resume(returning: ())
        }
    }

    func stopWatching() {
        NSFileCoordinator.removeFilePresenter(self)
    }

    func presentedItemDidChange() {
        onChange()
    }

    deinit {
        stopWatching()
    }
}

#endif
