# Improved Equality assertion

Making equality assertion more readable and maintainable.

## Overview

### Better error messaging

By default, when `XCTAssertEqual` fails it generates an error message by using the description of the object. This often
makes it difficult to find out what exactly is not the same between two values – particularly if they are reasonably
complicated types. ``TS/assert(_:equals:after:message:file:line:)-7f32a`` functionally behaves the same as
`XCTAssertEqual`; except that it will try to provide better error messages by producing a diff output between the two
types.

### Asserting values are effectively the same

Sometimes we may want to test that some values are “effectively the same” without them actually being “equal”.

For example, consider this code:

```swift
let first = URL(string: "https://example.com?b=1&a=2")!
let second = URL(string: "https://example.com?a=2&b=1")!
TS.assert(first, equals: second) // This fails
```

Even though these two URLs are not equal, in practice API contracts almost never care about the order of query items in
the URL. In these situations, when we write a test for an endpoint definition, ideally we should also not care about the
order of parameters.

This issue is even more sever if we consider structured data such as json. Two `String` or `Data` objects may be unequal
even if they contain the same json data due to how the json is formatted.

``Normalization`` type provides a systematic way for us to normalise these types before comparing them. We can refine
the assertion noted above by changing our assertion to normalise the URLs before comparing them:

```swift
let first = URL(string: "https://example.com?b=1&a=2")!
let second = URL(string: "https://example.com?a=2&b=1")!
TS.assert(first, equals: second, after: .normalizingForTesting) // This passes
```

``TestingSupport`` provides a few built-in normalisations, but it’s easy to create new `Normalization` objects that
apply to specific testing needs.

## Topics

### Asserting equality

- ``TS/assert(_:equals:after:message:file:line:)-7f32a``
- ``TS/assert(_:equals:after:message:file:line:)-1k8og``

### Normalising values for equality checking

- ``Normalization``
