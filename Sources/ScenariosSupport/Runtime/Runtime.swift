import Foundation

/// A namespace for operations related to runtime.
public enum Runtime {
    
    /// Returns all classes that (directly or indirectly) conform to ``RuntimeDiscoverable``.
    ///
    /// Calling this method has a non-trivial overhead, so you should process and cache the result as appropriate.
    public static var allDiscoveredClasses: some Sequence<RuntimeDiscoverable.Type> {
        // AnyClass.init seems to register new objective-C class the first time it is called.
        //
        // In order for the count variable to reserve enough capacity, we call this method once
        // so that any new classes are registered to the runtime.
        _ = [AnyClass](unsafeUninitializedCapacity: Int(1)) { buffer, initialisedCount in
            initialisedCount = 0
        }

        // Improved thanks to some hints from https://stackoverflow.com/a/54150007
        let count = objc_getClassList(nil, 0)
        let classes = [AnyClass](unsafeUninitializedCapacity: Int(count)) { buffer, initialisedCount in
            let autoreleasingPointer = AutoreleasingUnsafeMutablePointer<AnyClass>(buffer.baseAddress)
            initialisedCount = Int(objc_getClassList(autoreleasingPointer, count))
        }
        
        return classes
            .lazy
            // The `filter` is necessary. Without it we may crash.
            //
            // The cast using `as?` calls some objective-c methods on the type to check for conformance. But certain
            // system types do not implement that method and would cause a crash (possible bug in the runtime?).
            //
            // `class_conformsToProtocol` is safe to call on all types, so we use it to filter down to “our” classes
            // we try to cast them.
            .filter { class_inherited_conformsToProtocol($0, RuntimeDiscoverable.self) }
            .compactMap { $0 as? RuntimeDiscoverable.Type }
    }
    
}

private func class_inherited_conformsToProtocol(_ cls: AnyClass, _ p: Protocol) -> Bool {
    if class_conformsToProtocol(cls, p) { return true }
    guard let sup = class_getSuperclass(cls) else { return false }
    return class_inherited_conformsToProtocol(sup, p)
}
