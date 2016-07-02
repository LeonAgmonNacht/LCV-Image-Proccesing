//
//  RotatedCalipers.swift
//  VisionMacApp
//
//  Created by לאון אגמון נכט on 01/06/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import Foundation
import Darwin
import GLKit

// MARK: - Minimum Area Rectangle Enclosing a Convex Polygon

extension ConvexPolygon {
    /**
     the algorithm of this method can be found here: http://docs.lib.purdue.edu/cgi/viewcontent.cgi?article=1381&context=cstech
     - returns: the min(rotated) enclosing rectangle of the points in self
     */
    func getMinEnclosingRect() -> RotatedRectangle {
        
        // we define a support line a line that touches one of the points of the convex points
        /// the found min enclosing rectangle
        var minRect: RotatedRectangle = RotatedRectangle(points: [], slope: 0, height: FLT_MAX, width: FLT_MAX)
        
        let pointsCount = points.count
        /// the support line index
        var checkSupportIndex: Int = 0
        /// the parallel line to the found support index
        var supportParallelIndex: Int = 0
        /// the parallel line index to the current edge
        var edgeSupportParallelIndex: Int = 0
        
        for edgeIndex in 0...points.count-1 {
            
            // finding the first perpendicular support line
            while getDotProduct(index1: edgeIndex, index2: checkSupportIndex) > 0.0 {
                checkSupportIndex += 1
                checkSupportIndex %= pointsCount
            }
            // finding the parallel line to the current edge line
            if edgeIndex == 0 { edgeSupportParallelIndex = checkSupportIndex }
            while getCrossProduct(index1: edgeIndex, index2: edgeSupportParallelIndex) > 0.0 {
                edgeSupportParallelIndex += 1
                edgeSupportParallelIndex %= pointsCount
            }
            // finding the other perpendicular support line
            if edgeIndex == 0 { supportParallelIndex = edgeSupportParallelIndex }
            while getDotProduct(index1: edgeIndex, index2: supportParallelIndex) < 0.0 {
                supportParallelIndex += 1
                supportParallelIndex %= pointsCount
            }
            // finding the area of the bounding rectangle
            var distance1: Float = 0
            var distance2: Float = 0
            var slope: Float = 0
            
            
            if points[edgeIndex].1 == points[(edgeIndex + 1) % pointsCount].1 {
                // substracting two negative sides of the rectnagle
                distance1 = Float(abs(points[edgeSupportParallelIndex].1 - points[edgeIndex].1))
                distance2 = Float(abs(points[supportParallelIndex].0 - points[checkSupportIndex].0))
            }
            else if points[edgeIndex].0 == points[(edgeIndex + 1) % pointsCount].0 {
                distance1 = Float(abs(points[edgeSupportParallelIndex].0 - points[edgeIndex].0))
                distance2 = Float(abs(points[supportParallelIndex].1 - points[checkSupportIndex].1))
            }
            else {
                let edgePoint = getFloatRepOfPointFromIndex(index: edgeIndex)
                let nextEdgeIndex = getFloatRepOfPointFromIndex(index: (edgeIndex + 1) % pointsCount)
                let oppositeSide = getFloatRepOfPointFromIndex(index: edgeSupportParallelIndex)
                let closeSideFirst = getFloatRepOfPointFromIndex(index: checkSupportIndex)
                let closeSideOther = getFloatRepOfPointFromIndex(index: supportParallelIndex)
                
                slope = (nextEdgeIndex.0 - edgePoint.0) / (nextEdgeIndex.1 - edgePoint.1)
                distance1 = getPerpendicularDistance(x1: edgePoint.1,
                                                     y1: edgePoint.0,
                                                     x2: oppositeSide.1,
                                                     y2: oppositeSide.0,
                                                     s: slope)
                distance2 = getPerpendicularDistance(x1: closeSideFirst.1,
                                                     y1: closeSideFirst.0,
                                                     x2: closeSideOther.1,
                                                     y2: closeSideOther.0,
                                                     s: -1/slope)
                
            }
            var foundPoints = [(Int, Int)]()
            if slope != 0 {
                foundPoints = [points[edgeIndex],
                               points[edgeSupportParallelIndex],
                               points[checkSupportIndex],
                               points[supportParallelIndex]]
            }
            else {
                foundPoints = [points[checkSupportIndex],
                               points[supportParallelIndex],
                               points[edgeIndex],
                               points[edgeSupportParallelIndex]]
            }
            let size = distance1 * distance2
            if size < minRect.size {
                minRect = RotatedRectangle(points: foundPoints,
                                           slope: slope,
                                           height: distance1,
                                           width:  distance2)
            }
        }
        
        return minRect
        
    }
    
    // MARK: - Helper Methods
    
    /**
     - returns: the dot product of the vectors from vectices index1 to
     index1 +1 and index2 to index2 + 1
     
     - parameter index1: the index in the points of self which correspond to the wanted point
     - parameter index2: the index in the points of self which correspond to the wanted point
     */
    private func getDotProduct(index1: Int, index2: Int) -> Float {
        
        return applyOperation(index1: index1, index2: index2, operation: GLKVector3DotProduct)
    }
    /**
     - returns: the cross product of the vectors from vectices index1 to
     index1 +1 and index2 to index2 + 1
     
     - parameter index1: the index in the points of self which correspond to the wanted point
     - parameter index2: the index in the points of self which correspond to the wanted point
     */
    private func getCrossProduct(index1: Int, index2: Int) -> Float {
        return applyOperation(index1: index1, index2: index2, operation: { (v1, v2) -> Float in
            return GLKVector3CrossProduct(v1, v2).z
        })
    }
    /**
     - parameter x1: the known x coord of the line
     - parameter y1: the known y coord of the line
     - parameter s: the known slope of the line
     - parameter x2: the known x coord of point to calculate the perpendicular distance from
     - parameter y2: the known y coord of point to calculate the perpendicular distance from
     - returns: the perpendicular distance between the line x1,y1 with the slope s to the point x2,y2
     */
    private func getPerpendicularDistance(x1: Float,y1: Float,x2: Float,y2: Float,s: Float) -> Float {
        let a: Float = -s
        let b: Float = 1
        let c: Float = -y1 - a*x1
        // ^ the line of x1, y1, with the slope s. in the form of: ax + by + c = 0)
        return abs(a*x2 + b*y2 + c)/sqrt(pow(a,2) + pow(b,2))
        
    }
    // MARK: - Private Methods
    
    /**
     - returns: the 3D tuple( z coord = 0) representing the point points[index]. the returned tuple is a tuple of floats
     - parameter index: the index of the wanted point in self.points to calculate and return the data for
     */
    private func getFloatRepOfPointFromIndex(index: Int) -> (Float, Float, Float) {
        let point = points[index]
        return (Float(point.0), Float(point.1), Float(0))
    }
    /**
     applies the given operation on the two vectors v1, v2. where vi = points[i](as vector) substrcut vector points[indexi + 1](as vector)
     NOTE: if i+1 is out of bounds the value (i+1) % points.count will be used
     
     - parameter index1: the index to get the first vector from self.points
     - parameter index2: the index to get the second vector from self.points
     - returns: operation(v1, v2). where vi = points[indexi](as GLKVector3) substrcut vector points[indexi + 1](as GLKVector3)
     */
    private func applyOperation(index1: Int, index2: Int, operation: ((GLKVector3, GLKVector3) -> Float)) -> Float {
        let pointCount = points.count
        let fpoint11 = getFloatRepOfPointFromIndex(index: index1)
        let fpoint12 = getFloatRepOfPointFromIndex(index: (index1 + 1) % pointCount)
        let leftVector = GLKVector3Subtract(GLKVector3(v: fpoint11), GLKVector3(v: fpoint12))
        
        let fpoint21 = getFloatRepOfPointFromIndex(index: index2)
        let fpoint22 = getFloatRepOfPointFromIndex(index: (index2 + 1) % pointCount)
        let rightVector = GLKVector3Subtract(GLKVector3(v: fpoint21), GLKVector3(v: fpoint22))
        
        return operation(leftVector, rightVector)
        
    }
}

// MARK: - Helper Classes
/**
 a class representing a rotated rectangle using an angle, points and more
 */
struct RotatedRectangle: RectangleProtocol {
    /// the points the rectangle can be defined with, NOTE that those points aren't the corners of the rectangle, those can be retrived using rectangleCorners getRectangleCorners()
    var points: [(Int, Int)]
    /// the slope of the support line the rectangle was defined with, NOTE that this isn't the angle of the rectangle, this is angle
    var slope: Float
    /// the size, height*width of the rectangle
    var size: Float = -1
    /// the height of the rectangle
    var height: Float = -1
    /// the width of the rectangle
    var width: Float = -1
    /// the angle of the rotated rectangle
    var angle: Float
    /**
     - parameter points: the points the rectangle can be defined with, probably points from the convexHull of the object.
     - parameter slope: the slope of the support line the rectangle was defined
     - parameter height: the height of the rectangle, optional
     - parameter width: the width of the rectangle, optional
     */
    init(points: [(Int, Int)], slope: Float, height: Float = -1, width: Float = -1) {
        self.points = points
        self.slope = slope
        self.angle = slope*45
        if height != -1 && width != -1 {
            self.size = width*height
            self.height = height
            self.width = width
        }
    }
    /**
     - returns: the corners of the rectangle the struct represents, Precondision: points, slope is set
     */
    func getRectangleCorners() -> [(Int, Int)] {
        let boxPoint1 = self.getIntercectPoint(x1: self.points[2].0,
                                               y1: self.points[2].1,
                                               x2: self.points[0].0,
                                               y2: self.points[0].1,
                                               s: -self.slope)
        
        let boxPoint2 = self.getIntercectPoint(x1: self.points[3].0,
                                               y1: self.points[3].1,
                                               x2: self.points[0].0,
                                               y2: self.points[0].1,
                                               s: -self.slope)
        let boxPoint3 = self.getIntercectPoint(x1: self.points[2].0,
                                               y1: self.points[2].1,
                                               x2: self.points[1].0,
                                               y2: self.points[1].1,
                                               s: -self.slope)
        
        let boxPoint4 = self.getIntercectPoint(x1: self.points[3].0,
                                               y1: self.points[3].1,
                                               x2: self.points[1].0,
                                               y2: self.points[1].1,
                                               s: -self.slope)
        return [boxPoint2, boxPoint1, boxPoint3, boxPoint4]
        
    }
    /**
     - returns: the point of interection of the two lines: the line defined by the x1,y1 and the slope s, and the line defined by x2,y2 and the slope -1/s (meaning the perpendicular line to the first line)
     - parameter (x1,y1): the first point to use, the belongs to the first line
     - parameter (x2, y2): the second point to use, that belongs to the second line
     - parameter s: the slope of the first line
     */
    private func getIntercectPoint(x1: Int,y1: Int,x2: Int, y2: Int, s: Float)-> (Int, Int) {
        // those were calculate using the point slope equation for line and the comparison of two lines when the second line has a slope of -1/s and by that he is perpendicular to the other line
        let xValueUpper = Float(x1) * pow(s,2) - Float(y1)*s + Float(x2) + Float(y2)*s
        let xValueLower = (pow(s,2) + 1)
        let xValue = xValueUpper/xValueLower
        let yValue = s*xValue - Float(x1)*s + Float(y1)
        
        return (Int(xValue), Int(yValue))
    }
}
