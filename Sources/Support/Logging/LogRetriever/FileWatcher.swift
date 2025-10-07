#if canImport(Darwin)

import Foundation

class FileWatcher: NSObject {
    private var presenters: [FilePresenter] = []
    private let onChange: () -> Void

    init(urls: [URL], onChange: @escaping () -> Void) {
        self.onChange = onChange
        super.init()

        presenters = urls.map { url in
            FilePresenter(url: url) { [weak self] in
                self?.onChange()
            }
        }
    }

    func startWatching() throws {
        for presenter in presenters {
            try presenter.startWatching()
        }
    }

    func stopWatching() {
        for presenter in presenters {
            presenter.stopWatching()
        }
    }

    deinit {
        stopWatching()
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

    func startWatching() throws {
        NSFileCoordinator.addFilePresenter(self)
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
