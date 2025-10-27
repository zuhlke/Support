#if canImport(ObjectiveC)
import Foundation
import ScenariosSupport
import TestingSupport
import XCTest

class RuntimeTests: XCTestCase {
    
    func testDiscoversDirectConformanceTypes() {
        TS.assert(Runtime.allDiscoveredClasses.count(where: { $0 is FinalDirectConformance.Type }), equals: 1)
        
        TS.assert(Runtime.allDiscoveredClasses.count(where: { $0 is DirectConformance.Type }), equals: 2)
        TS.assert(Runtime.allDiscoveredClasses.count(where: { $0 is InheritedFromDirectConformance.Type }), equals: 1)
    }
    
    func testDiscoversTypesConformingToAProtocol() {
        TS.assert(Runtime.allDiscoveredClasses.count(where: { $0 is Intermediate.Type }), equals: 3)
        TS.assert(Runtime.allDiscoveredClasses.count(where: { $0 is FinalConformanceViaProtocol.Type }), equals: 1)
        TS.assert(Runtime.allDiscoveredClasses.count(where: { $0 is ConformanceViaProtocol.Type }), equals: 2)
        TS.assert(Runtime.allDiscoveredClasses.count(where: { $0 is InheritedConformanceViaProtocol.Type }), equals: 1)
    }
    
}

private final class FinalDirectConformance: RuntimeDiscoverable {}

private class DirectConformance: RuntimeDiscoverable {}
private class InheritedFromDirectConformance: DirectConformance {}

private protocol Intermediate: RuntimeDiscoverable {}
private final class FinalConformanceViaProtocol: Intermediate {}

private class ConformanceViaProtocol: Intermediate {}
private class InheritedConformanceViaProtocol: ConformanceViaProtocol {}
#endif
