import Foundation

extension String {
    
    /// Returns a random `String`.
    ///
    /// Each invocation of this method creates a new random value.
    public static func random() -> String {
        UUID.random().uuidString
    }
    
}
