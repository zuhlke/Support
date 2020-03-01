import Foundation

// Implementation detail protocol to allow perforing generic
public protocol _OptionalType: ExpressibleByNilLiteral {
    associatedtype Wrapped
    static func _make(from optional: Wrapped?) -> Self
    func _asOptional() -> Wrapped?
}

extension Optional: _OptionalType {
    public static func _make(from optional: Wrapped?) -> Wrapped? {
        optional
    }
    
    public func _asOptional() -> Wrapped? {
        self
    }
}
