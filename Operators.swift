//
//  Operators.swift
//  VisionMacApp
//
//  Created by לאון אגמון נכט on 31/05/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import Foundation

// MARK: - Vector Operators

/**
 sums the two given tuples
 - returns: (first.0 + second.0, first.1 + second.1)
 */
func +(first:(Int, Int), second: (Int, Int)) -> (Int, Int) {
    return (first.0 + second.0, first.1 + second.1)
}
/**
 mult the two given tuples, component by scalar
 - returns: (first.0*scalar, first.1*scalar)
 */
func *(first:(Int, Int), scalar: Int) -> (Int, Int) {
    return (first.0*scalar, first.1*scalar)
}
