import Support
import TestingSupport
import XCTest

class PropertyTestRunnerTests: XCTestCase {
    
    func testGeneratingPrimitiveType() {
        let iterations = 72
        let runner = PropertyTestRunner(iterations: iterations)
        var callbackCount = 0
        runner.run(for: String.self) { s in
            callbackCount += 1
        }
        
        TS.assert(callbackCount, equals: iterations)
    }
    
    func testGeneratingCompoundClassType() {
        
        final class Data: AutoGeneratable {
            
            @Generated(configure: {
                $0.minimumCount = 2
                $0.maximumCount = 14
                $0.characters.allowedRange = .lowercaseASCII
            })
            var username: String
            
            @Generated(configure: {
                $0.minimumCount = 8
                $0.maximumCount = 14
                $0.characters.allowedRange = .lowercaseASCII
            })
            var password: String
            
            lazy var credentials = URLCredential(
                user: username,
                password: password,
                persistence: .forSession
            )
        }
        
        let iterations = 72
        let runner = PropertyTestRunner(iterations: iterations)
        var callbackCount = 0
        
        runner.run(for: Data.self) { s in
            callbackCount += 1
        }
        
        TS.assert(callbackCount, equals: iterations)
    }
    
    func testGeneratingCompoundStructType() {
        
        struct Data: AutoGeneratable {
            
            @Generated
            var username: String
            
            @Generated
            var password: String
            
            var credentials: URLCredential {
                URLCredential(
                    user: username,
                    password: password,
                    persistence: .forSession
                )
            }
        }
        
        let iterations = 72
        let runner = PropertyTestRunner(iterations: iterations)
        var callbackCount = 0
        
        runner.run(for: Data.self) { s in
            describe(s.credentials)
            callbackCount += 1
        }
        
        TS.assert(callbackCount, equals: iterations)
    }
    
    func testCombiningTwoBooleans() {
        
        struct Data: AutoGeneratable {
            
            @Generated
            var flag1: Bool
            
            @Generated
            var flag2: Bool
            
        }
        
        let iterations = 72
        let runner = PropertyTestRunner(iterations: iterations)
        var callbackCount = 0
        
        runner.run(for: Data.self) { s in
            callbackCount += 1
        }
        
        TS.assert(callbackCount, equals: iterations)
    }
    
}
