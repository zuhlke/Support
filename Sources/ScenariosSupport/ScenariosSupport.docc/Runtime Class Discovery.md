# Runtime Class Discovery

Rely on runtime to find classes conforming to a protocol.

## Overview

Sometimes after implementing a type we expect it to automatically “work”. For example, test types inheriting from
`XCTestCase` are automatically detected by the testing infrastructure and will run without us having to “register” them.

As another example, in an internal app we may want to provide entry points to make it easier to test various scenarios.
It helps both with maintainability and also developer experience if the app infrastructure can automatically detect and
use these types.

### Runtime discovery

``RuntimeDiscoverable`` is a marker protocol. It has no direct protocol requirements, though it can only be conformed to
from a class (so it’s available in Objective-C runtime). ``Runtime/allDiscoveredClasses`` then returns all classes that
conform to this protocol.

Since ``RuntimeDiscoverable`` has no requirements, normally it’s used in conjunction with a refinment protocol that
actually provides the functionality that you want to discover:

```swift
protocol Command: RuntimeDiscoverable { 
    static var name: String { get }
    static func run()
}

class Echo: Command {/*...*/}
class Cat: Command {/*...*/}

// An array containing `Echo.self` and `Cat.self`.
let commands = Runtime.allDiscoveredClasses.compactMap { $0 as? Command.Type }
```

## Topics

### Runtime Class Discovery

- ``RuntimeDiscoverable``
- ``Runtime``
