//
//  RectangleInterface.swift
//  LCV
//
//  Created by לאון אגמון נכט on 05/06/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import Foundation
/**
 a protocol for rectnagle methods, used mostly for drawing
 */
protocol RectangleProtocol {
    /**
     - returns: the corners of the rectangle
     */
    func getRectangleCorners() -> [(Int, Int)]

}