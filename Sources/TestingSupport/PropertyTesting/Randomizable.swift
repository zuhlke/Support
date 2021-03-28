import Foundation

protocol Randomizable {
    func randomize<RNG: RandomNumberGenerator>(with numberGenerator: inout RNG)
}
