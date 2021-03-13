
import Foundation

public protocol EmptyInitializable {
    init()
}

extension UUID: EmptyInitializable {}

extension Data: EmptyInitializable {}

extension Array: EmptyInitializable {}

extension Dictionary: EmptyInitializable {}

extension Set: EmptyInitializable {}
