import Foundation

#error("Change concept of `AutoGeneratable`")
// Making types automatically conform to `Generatable` causes us a few issues.
// With current swift limitations, we have to first `init` the type before we can do anything with it since `Mirror`
// only works on initialised types.
//
// * First, we have to `init` the "prototype" first to find the generated properties.
// * Then, we have to `init` a new "instance" for each iteration of object generation.
//
// This confuses the concept of prototype vs generated instance a lot. For example, what happens if `Generated` objects
// are configured differently on each run? At the very least, this is a performance bottleneck which can become
// significant on each iteration.
//
// One option would be to use static properties for the prototype and only initialise "generated" instances.
// Putting aside ergonomic issues (which take us half-way to the next solution anyway) static key paths are not
// supported at the moment, so this is not possible.
//
// Instead, suggestion is to make this type only be a prototype. Then, in each iteration we generate another type.
// That type would be dynamically callable; using generated values for `Generated` properties, and forwarding other
// properties to the type as normal. Some notes on this design:
//
// * The prototype and the `Generated` types are called only once during test set up (possibly in user-code).
// * We can still use "Mirror" to validate the type / initialise the test harness.
// * We can also dynamically optimise the test runner depending on which properties are called. For example, if we have
//   three properties and only two are actually used in the test, there's no point in generating cases for the third
//   property.
public protocol _AutoGeneratable: Generatable {
    init()
}

extension _AutoGeneratable {
    static var autoGenerationContext: AutoGenerationContext {
        print("CHILD dynamic", Self().generatedChildren)
        print("CHILD static", Self.staticGeneratedChildren)
        return AutoGenerationContext(nodes: Self().generatedChildren)
    }
}

struct AutoGenerationContext {
    var nodes: [String: _Generated.Type]
}

struct AutoGenerationNode {
    var type: String
}

private extension _AutoGeneratable {
    var generatedChildren: [String: _Generated.Type] {
        Dictionary(uniqueKeysWithValues: Mirror(reflecting: self).children.compactMap { label, child in
            guard let child = child as? _Generated else { return nil }
            guard let label = label else { Thread.fatalError("Expected `Generated` property to be labeled.") }
            return (label, type(of: child))
        })
    }
    static var staticGeneratedChildren: [String: _Generated.Type] {
        Dictionary(uniqueKeysWithValues: Mirror(reflecting: self).children.compactMap { label, child in
            guard let child = child as? _Generated else { return nil }
            guard let label = label else { Thread.fatalError("Expected `Generated` property to be labeled.") }
            return (label, type(of: child))
        })
    }
}
