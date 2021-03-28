import Support
import TestingSupport
import XCTest

@dynamicMemberLookup
struct Thingy<GenType: AutoRandomCasesGeneratable> {
    
    subscript<Value>(dynamicMember dynamicMember: KeyPath<GenType.Type, Value>) -> Value {
        GenType.self[keyPath: dynamicMember]
    }
}

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
        
        final class Data: AutoRandomCasesGeneratable {
            
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
            var password1: String
            
//            @Generated(configure: {
//                $0.minimumCount = 8
//                $0.maximumCount = 14
//                $0.characters.allowedRange = .lowercaseASCII
//            })
            static var password2: String = "45"
            
            lazy var credentials = URLCredential(
                user: username,
                password: password1,
                persistence: .forSession
            )
        }
        
        let s: KeyPath<Data.Type, String> = \.password2
        
        let t = Thingy<Data>()
        print(t.password2)
        
        let iterations = 72
        let runner = PropertyTestRunner(iterations: iterations)
        var callbackCount = 0
        
        runner.run(for: Data.self) { s in
            callbackCount += 1
        }
        
        TS.assert(callbackCount, equals: iterations)
    }
    
    func testGeneratingCompoundStructType() {
        
        struct Data: AutoRandomCasesGeneratable {
            
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
        
        struct Data: AutoRandomCasesGeneratable {
            
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
