import Foundation

public protocol GeneratableConfiguration {
    init()
}

public struct EmptyConfiguration: GeneratableConfiguration {
    public init() {}
}
