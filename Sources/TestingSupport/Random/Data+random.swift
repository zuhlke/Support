import Foundation

extension Data {
    
    /// Returns a random `Data`.
    ///
    /// Each invocation of this method creates a new random value.
    public static func random() -> Data {
        String.random().data(using: .utf8)!
    }
    
}
