//
//  File.swift
//
//
//  Created by Mo Ramezanpoor on 13/01/2020.
//

import Foundation

public struct HTTPHeaderFieldName: Equatable {
    public var lowercaseName: String
    
    public init(_ name: String) {
        lowercaseName = name.lowercased()
    }
}
