
import Foundation

public protocol EmptyInitializable {
    init()
}

extension UUID: EmptyInitializable {}

extension Data: EmptyInitializable {}
