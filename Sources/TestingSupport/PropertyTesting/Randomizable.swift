//
//  File.swift
//  
//
//  Created by Mo Ramezanpoor on 30/01/2021.
//

import Foundation

protocol Randomizable {
    func randomize<RNG: RandomNumberGenerator>(with numberGenerator: inout RNG)
}
