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
    
    var lowerRed: UInt8 = 0
    var lowerGreen: UInt8 = 80
    var lowerBlue: UInt8 = 0
    
    // upper color threshold
    
    var upperRed: UInt8 = 80
    var upperGreen: UInt8 = 255
    var upperBlue: UInt8 = 80
    
}
