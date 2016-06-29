//
//  BoundingRectangle.swift
//  LCV
//
//  Created by לאון אגמון נכט on 05/06/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import Foundation
import Darwin

// MARK: - Bounding (Straight) Rectangle

extension Contour {
    /**
     - returns: a straight bounding rectangle of the points in self. Precondition: the points in self should have at  least two points with difrrent row value and two points with difrrent col value
     */
    func getBoundingRectangle() -> Rectangle {
        // TODO: replace minX, minY to minY, minX and the same for max
        let minY = points[0][0].0
        let maxY = points.last![0].0
        
        var maxX = 0
        var minX = Int(INTMAX_MAX)
        for elem in points {
            if elem[0].1 < minX {
                minX = elem[0].1
            }
            if elem.last!.1 > maxX {
                maxX = elem.last!.1
            }
            
        }
        let topLeft = (minY, minX)
        let topRight = (minY, maxX)
        let bottomRight = (maxY, maxX)
        let bottomLeft = (maxY, minX)

        return Rectangle(points: [topLeft, topRight, bottomRight, bottomLeft])
        
    }
}
/// a struct representing a straight rectangle using 4 points
struct Rectangle: RectangleProtocol {
    /// the four points that define self, in the following order: topLeft, topRight, bottomRight, bottomLeft
    private var points: [(Int, Int)]
    /**
     init a straight(angle = 0) rectangle using 4 points
     - parameter points: the points that define the rectangle(the rectangle's corners) in the following order:
     - topLeft
     - topRight 
     - bottomRight
     - bottomLeft
     */
    init(points: [(Int, Int)]) {
        self.points = points
    }
    /**
     - returns: the points that are the corners of the rectangle
     */
    func getRectangleCorners() -> [(Int, Int)] {
        return points
    }
}