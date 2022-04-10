# Scoping Mutation

API to help scope of mutations.

## Overview

In many situations, a type needs to be configured right after it is initialised:

```swift
var components = URLComponents()
components.scheme = "https"
components.host = "example.com"
components.path = "/service"
let url = components.url!
components.port = 88
```

```swift
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
let content = try decoder.decode(Content.self, from: data)
```

In these code snippets, the mutation is a natural part of the initialisation, but this is not clearly evident from the code structure.
Also, in the first example, `components` has to be marked as a `var`, so the compiler can’t help detect potential issues, like the `port` being set after the component is used.

The `mutating` function provides a scope for preparing the types in a way that the intention is more clear:

```swift
let components = mutating(URLComponents()) {
    $0.scheme = "https"
    $0.host = "example.com"
    $0.path = "/service"
}
let url = components.url!
components.port = 88 // Error: Cannot assign to property: 'components' is a 'let' constant
```

```swift
let decoder = mutating(JSONDecoder()) {
    $0.dateDecodingStrategy = .iso8601
}
let content = try decoder.decode(Content.self, from: data)
```


## Topics

### Scoping Mutation

- ``mutating(_:with:)``
