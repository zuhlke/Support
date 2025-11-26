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
        let convention = ...// see LogStorageConvention for usuage
        guard let logMonitor = LogMonitor(
            convention: convention
        ) else {
            // Handle nil logMonitor
        }
    }
}
```

## Topics

### Storage conventions

- ``LogStorageConvention``

### Monitoring logs

- ``LogMonitor``
- ``BundleMetadata``
