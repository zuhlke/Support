#if canImport(Darwin)
import Foundation
import Dispatch

protocol DirectoryWatcherDelegate: AnyObject {
    func directoryWatcher(_ watcher: DirectoryWatcher, didDetectChangesAt url: URL)
}

enum DirectoryWatcherError: Error {
    case failedToOpenDirectory(URL)
}

class DirectoryWatcher {
    weak var delegate: DirectoryWatcherDelegate?
    private let directoryURL: URL
    private var source: DispatchSourceFileSystemObject?
    private let queue = DispatchQueue(label: "com.zuhlke.Support.DirectoryWatcher", qos: .utility)

    init(directoryURL: URL, delegate: DirectoryWatcherDelegate? = nil) {
        self.directoryURL = directoryURL
        self.delegate = delegate
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
            self.delegate?.directoryWatcher(self, didDetectChangesAt: self.directoryURL)
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
