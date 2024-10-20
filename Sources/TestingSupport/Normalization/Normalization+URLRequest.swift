import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Support

extension Normalization<URLRequest> {
    
    /// Normalises the URL request for the purpose of testing.
    public static let normalizingForTesting = Normalization {
        mutating($0) {
            $0.url = Normalization<URL>.normalizingForTesting.normalize($0.url!)
        }
    }
    
}
