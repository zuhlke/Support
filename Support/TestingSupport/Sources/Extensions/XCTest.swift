import XCTest

public extension XCTest {
    
    /// Returns the bundle the test class belongs to.
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
}
