#if LoggingFeature
#if canImport(Darwin)

import Foundation
import Dispatch

class MultiDirectoryWatcher {
    private var watchers: [DirectoryWatcher] = []
    private let onDirectoryChange: (() -> Void)?

    init(urls: [URL], onDirectoryChange: (() -> Void)? = nil) {
        self.onDirectoryChange = onDirectoryChange
        watchers = urls.map { url in
            DirectoryWatcher(directoryURL: url) { [weak self] in
                self?.onDirectoryChange?()
            }
        }
    }

    func startWatching() throws {
        for watcher in watchers {
            try watcher.startWatching()
        }
    }

    func stopWatching() {
        for watcher in watchers {
            watcher.stopWatching()
        }
    }

    deinit {
        stopWatching()
    }
}

enum DirectoryWatcherError: Error {
    case failedToOpenDirectory(URL)
}

class DirectoryWatcher {
    private let queue = DispatchQueue(label: "com.zuhlke.Support.DirectoryWatcher", qos: .utility)

    private let directoryURL: URL
    private var source: DispatchSourceFileSystemObject?
    private let onDirectoryChange: (() -> Void)?

    init(directoryURL: URL, onDirectoryChange: (() -> Void)? = nil) {
        self.directoryURL = directoryURL
        self.onDirectoryChange = onDirectoryChange
    }

    func startWatching() throws {
        guard source == nil else { return }

        let descriptor = open(directoryURL.path, O_EVTONLY)
        guard descriptor >= 0 else {
            throw DirectoryWatcherError.failedToOpenDirectory(directoryURL)
        }

        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: [.write],
            queue: queue
        )

        source?.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.onDirectoryChange?()
        }

        source?.setCancelHandler {
            close(descriptor)
        }

        source?.resume()
    }

    func stopWatching() {
        source?.cancel()
        source = nil
    }

    deinit {
        stopWatching()
    }
}

#endif
#endif
