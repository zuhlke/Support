import XCTest

extension XCTest {
    
    /// Returns the bundle the test class belongs to.
    public var bundle: Bundle {
        Bundle(for: type(of: self))
    }
    
}
