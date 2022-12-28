import Foundation

extension UUID {
    
    /// Returns a random `UUID`.
    ///
    /// Each invocation of this method creates a new random value.
    public static func random() -> UUID {
        UUID()
    }
    
}
