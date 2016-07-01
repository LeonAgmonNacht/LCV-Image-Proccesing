//
//  RectangleDrawing.swift
//  LCV
//
//  Created by לאון אגמון נכט on 03/06/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import UIKit
/**
 manages the drawing of rectangles on an image
 */
class RectangleDrawing: UIView {
    /**
     returns the points on the line determinated by the points point1, point2
     - Algorithem: Bresenham's line algorithm
     - returns: an array of the points (in the format (row, col)) that are on the line the point1,2 define
     - parameter point1: the first points to use in order to determinate the line
     - parameter point2: the second points to use in order to determinate the line
     */
    private static func getPointsForLineThrow(point1: (Int, Int), point2: (Int, Int)) -> [(Int, Int)] {
        var resultPoints = [(Int, Int)]()
        let dx = Float(abs(point1.0 - point2.0))
        let dy = Float(abs(point1.1 - point2.1))
        let sx = point1.0 > point2.0 ? -1 : 1
        let sy = point1.1 > point2.1 ? -1 : 1
        var tempX = point1.0
        var tempY = point1.1
        
        if dx > dy {
            var err = Float(dx) / 2
            while tempX != point2.0 {
                resultPoints.append((tempX, tempY))
                err -= dy
                if err < 0 {
                    tempY += sy
                    err += dx
                }
                tempX += sx
            }
        }
        else {
            var err = Float(dy) / 2
            while tempY != point2.1 {
                resultPoints.append((tempX, tempY))
                err -= dx
                if err < 0 {
                    tempX += sx
                    err += dy
                }
                tempY += sy
            }
            
        }
        resultPoints.append((tempX, tempY))
        return resultPoints
    }
    /**
     draws the line determinated by the points point1, point2 on the image image
     - parameter image: the image to draw the line on
     - parameter point1: the first points to use in order to determinate the line
     - parameter point2: the second points to use in order to determinate the line
     - parameter color: the color to draw the line
     */
    private static func drawLine(image: ColorImage, point1:(Int, Int), point2:(Int, Int), color:(UInt8, UInt8, UInt8)) {
        let points = getPointsForLineThrow(point1: point1, point2: point2)
        for point in points {
            // TODO: Fix point index error
            if image.isValidIndexForPixel(index: point) {
                image[point] = ColorPixel(r: color.0, g: color.1, b: color.2, a: 255)
            }
        }
    }
    /**
     draws a rectangle on the given image using the points in the given rectangle instance with the color color
     - parameter rect: the rectangle to get the points from in order to draw the rectnagle
     - parameter image: the image to draw the line on
     - parameter color: the color to draw the line with
     */
    static func drawRectangle(image: ColorImage, rect: RectangleProtocol, color:(UInt8, UInt8, UInt8)) {
        let points = rect.getRectangleCorners()
        for i in 0...points.count-1 {
            drawLine(image: image, point1: points[i], point2: points[(i+1) % points.count], color: color)
        }
    }
}
