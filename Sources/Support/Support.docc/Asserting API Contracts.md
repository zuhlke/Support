# Asserting API Contracts

Write more testable asserting APIs.

## Overview

Some API contract assumptions can’t be reasonably expressed in a way that can be confirmed at compile time.
In these situations it’s often better to assert that the preconditions are met at runtime instead of silently continuing
and causing unexpected issues later down the line.

``Supervisor`` provides API that makes it easier to writing testable assertions.

### Enforcing API contracts

Imagine an API that can load some configuration from a URL:

```swift
func load(_ url: URL) -> Configuration
```

This method is not marked as async as it’s expected to be pointing to a local resource.

It is also not marked as throwing, as the expectation is that the configuration is that the contents of the URL is 
already validated to exist and have the right format (e.g. is embedded in the app bundle).

If `Configuration` type is `Decodable`, we may implement this function in this way:

```swift
func load(_ url: URL) -> Configuration {
    let data = try! Data(contentsOf: url)
    return try! JSONDecoder().decode(Configuration.self, from: data)
}
```

This implementation doesn’t actually enforce our expecation that `url` is a local file reference, and may in fact block
the call for a significant period of time. We can add a precondition to detect this:

```swift
func load(_ url: URL) -> Configuration {
    precondition(url.isFileURL, "`url` must be for a local resource.")
    let data = try! Data(contentsOf: url)
    return try! JSONDecoder().decode(Configuration.self, from: data)
}
```

### Testing for assertions

Unfortunately, we can’t easily test our `precondition`. Any input that would cause the precondition to fail would
actually cause the test itself to crash:

```swift
func testRemoteURLIsNotAccepted() {
    let url = URL(string: "https://example.com")!
    _ = load(url) // This immediately crashes
}
```

In order to test this API, we can use ``Supervisor``. `Supervisor` provides a proxy API for precondition API, so we
can change our `load` function to this:

```swift
func load(_ url: URL) -> Configuration {
    Supervisor.precondition(url.isFileURL, "`url` must be for a local resource.")
    let data = try! Data(contentsOf: url)
    return try! JSONDecoder().decode(Configuration.self, from: data)
}
```

By default, this method behaves exactly as before. However, during a test we can “supervise” the function call to detect
the precondition call instead of immediately crashing:

```swift
func testRemoteURLIsNotAccepted() {
    let url = URL(string: "https://example.com")!
    let exitManner = Supervisor.detachSyncSupervised {
        _ = load(url)
    }
    XCTAssertEqual(exitManner, .fatalError)
}
```

## Topics

### Controlling assertions 

- ``Supervisor``
