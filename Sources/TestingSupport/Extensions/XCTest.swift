import XCTest

extension XCTest {
    
    /// Returns the bundle the test class belongs to.
    public var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
}
