import Foundation

protocol SeedableRandomNumberGenerator: RandomNumberGenerator {
    
    init(seed: UInt64)
    
}
