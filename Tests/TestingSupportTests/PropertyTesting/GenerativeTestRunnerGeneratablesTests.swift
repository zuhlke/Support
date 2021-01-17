import Support
import TestingSupport
import XCTest

class GenerativeTestRunnerGeneratablesTests: XCTestCase {
    
    // MARK: ExhaustiveGeneratables
    
    func testRunningForExhaustiveGeneratableType() {
        let runner = GenerativeTestRunner()
        
        var values = [Int]()
        runner.run(for: Int.self) {
            $0.range = 1 ... 10
        } action: {
            values.append($0)
        }
        
        TS.assert(values, equals: Array(1 ... 10))
    }
    
}
