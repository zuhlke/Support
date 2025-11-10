# Logging

@Metadata {
    @Available(iOS, introduced: "17.0")
    @Available(macOS, introduced: "14.0")
    @Available(tvOS, introduced: "17.0")
    @Available(watchOS, introduced: "10.0")
}

Code to monitor and retrieve logs generated using a Logger. 

## Overview

Use ``LogMonitor`` in your application to begin observing logs made to OSLog, and publishing them to SwiftData.

```swift
@main
struct YourApp: App {
    var logMonitor: LogMonitor?

    init {
        do {
            guard let bundleMetadata = BundleMetadata(from: Bundle.main) else {
                // Handle nil bundle metadata
            }

            let convention = ...// see LogStorageConvention for usuage
            let logMonitor = try! LogMonitor(
                convention: convention,
                bundleMetadata: bundleMetadata
            )
        } catch {
            // Handle error from instantiating LogMonitor
        }
    }
}
```

Use ``LogRetriever`` to retrieve logs published to SwiftData.

```swift
@main
struct YourLogView: View {
    var logRetriever: LogRetriever?

    init { 
        do {
            let convention = ...// this should be the same convention used with LogMonitor
            logRetriever = try LogRetriever(convention: convention)
        } catch {
            // Handle error from instantiating LogMonitor
        }
    }

    public var body: some View {
        // You can use logRetriever.apps to generate your chosen UI
    }
}
```

## Topics

### Storage conventions

- ``LogStorageConvention``

### Monitoring logs

- ``LogMonitor``
- ``BundleMetadata``

### Retrieving logs

- ``LogRetriever``
- ``AppLogContainer``
- ``ExecutableLogContainer``
