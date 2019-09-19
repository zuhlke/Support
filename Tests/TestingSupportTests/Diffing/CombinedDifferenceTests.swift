import XCTest
import Support
@testable import TestingSupport

class CombinedDifferenceTests: XCTestCase {
    
    func testDiffingFromAnEmptyArrayAddsAllElements() {
        let newArray = Array<UUID>.random(length: 10)
        let actual = newArray.combinedDifference(from: [])
        let expected = newArray.map { CombinedDifference(element: $0, change: .added) }
        
        XCTAssertEqual(actual, expected)
    }
    
    func testDiffingToAnEmptyArrayRemovesAllElements() {
        let newArray = Array<UUID>.random(length: 10)
        let actual = [].combinedDifference(from: newArray)
        let expected = newArray.map { CombinedDifference(element: $0, change: .removed) }
        
        XCTAssertEqual(actual, expected)
    }
    
    func testDiffingToSameArrayLeavesElementsUnchanged() {
        let newArray = Array<UUID>.random(length: 10)
        let actual = newArray.combinedDifference(from: newArray)
        let expected = newArray.map { CombinedDifference(element: $0, change: .none) }
        
        XCTAssertEqual(actual, expected)
    }
    
    func testDiffingToSameArrayWithLastElementRemoved() {
        let newArray = Array<UUID>.random(length: 10)
        let modified = mutating(newArray) {
            $0.removeLast()
        }
        let actual = modified.combinedDifference(from: newArray)
        var expected = newArray.map { CombinedDifference(element: $0, change: .none) }
        expected[9].change = .removed
        
        XCTAssertEqual(actual, expected)
    }
    
}

private extension Array where Element == UUID {
    
    static func random(length: Int) -> [UUID] {
        return (0..<length).map { _ in UUID() }
    }
    
}
