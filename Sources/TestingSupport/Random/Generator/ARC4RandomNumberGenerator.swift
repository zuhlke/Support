import Foundation

// Using Implementation from Swift TensorFlow implementation:
//
// Licensed under Apache License v2.0 with Runtime Library Exception
// https://github.com/apple/swift/blob/bc8f9e61d333b8f7a625f74d48ef0b554726e349/stdlib/public/TensorFlow/Random.swift

/// A seeded random number generator.
public struct ARC4RandomNumberGenerator: SeedableRandomNumberGenerator {
    private var state: [UInt8] = Array(0 ... 255)
    private var iPos: UInt8 = 0
    private var jPos: UInt8 = 0
    
    /// Creates a new random number generator.
    ///
    /// - Parameter seed: The seed for the generator.
    public init<T: BinaryInteger>(seed: T) {
        var newSeed: [UInt8] = []
        for i in 0 ..< seed.bitWidth / UInt8.bitWidth {
            newSeed.append(UInt8(truncatingIfNeeded: seed >> (UInt8.bitWidth * i)))
        }
        self.init(seed: newSeed)
    }
    
    /// Initialize ARC4RandomNumberGenerator using an array of UInt8. The array
    /// must have length between 1 and 256 inclusive.
    private init(seed: [UInt8]) {
        precondition(seed.count > 0, "Length of seed must be positive")
        precondition(seed.count <= 256, "Length of seed must be at most 256")
        var j: UInt8 = 0
        for i: UInt8 in 0 ... 255 {
            j &+= S(i) &+ seed[Int(i) % seed.count]
            swapAt(i, j)
        }
    }

    /// Produce the next random UInt64.
    public mutating func next() -> UInt64 {
        var result: UInt64 = 0
        for _ in 0 ..< UInt64.bitWidth / UInt8.bitWidth {
            result <<= UInt8.bitWidth
            result += UInt64(nextByte())
        }
        return result
    }

    // Helper to access the state.
    private func S(_ index: UInt8) -> UInt8 {
        state[Int(index)]
    }

    // Helper to swap elements of the state.
    private mutating func swapAt(_ i: UInt8, _ j: UInt8) {
        state.swapAt(Int(i), Int(j))
    }

    // Generates the next byte in the keystream.
    private mutating func nextByte() -> UInt8 {
        iPos &+= 1
        jPos &+= S(iPos)
        swapAt(iPos, jPos)
        return S(S(iPos) &+ S(jPos))
    }
}
