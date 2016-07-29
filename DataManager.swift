//
//  DataManager.swift
//  LCV
//
//  Created by לאון אגמון נכט on 01/07/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import Foundation
/**
 a class to handle all changable data for the demo
 */
class DataManager {
    
    /// the shared instance to be used
    static var sharedInstance = DataManager()
    
    
    // lower color threshold
    
    var lowerRed: UInt8 = 100
    var lowerGreen: UInt8 = 53
    var lowerBlue: UInt8 = 67
    
    // upper color threshold
    
    var upperRed: UInt8 = 255
    var upperGreen: UInt8 = 104
    var upperBlue: UInt8 = 132
    
}
