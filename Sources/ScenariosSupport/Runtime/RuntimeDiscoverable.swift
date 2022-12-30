import Foundation

/// A protocol that marks types to be found at runtime.
///
/// Normally, you don’t conform a type directly to ``RuntimeDiscoverable``. Instead, you can use it as the base for a protocol that other types conform to.
@objc public protocol RuntimeDiscoverable: AnyObject {}
