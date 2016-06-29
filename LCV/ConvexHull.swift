//
//  ConvexHull.swift
//  VisionMacApp
//
//  Created by לאון אגמון נכט on 31/05/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import Foundation
import GLKit

// MARK: - Convex Hull
extension Contour {
    /**
     creates and returns the convex hull of self
     - algorithem: https://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain
     - returns: a ConvexPolygon instance holding points of the convex hull
     */
    func convexHull() -> ConvexPolygon {
        // lower points of convex hull
        var lowerPoints: [(Int, Int)] = []
        // upper points of convex hull
        var upperPoints: [(Int, Int)] = []
        // getting the sorted points as a 1D array
        let flattenPoints = self.getPoints().flatten()
        // lower points
        for point in flattenPoints {
            while lowerPoints.count >= 2 {
                let last = lowerPoints.last!
                let preLast = lowerPoints[lowerPoints.count - 2]
                
                if getCrossProduct(o: preLast, a: last, b: point) > 0 {
                    break
                }
                lowerPoints.removeLast()
            }
            lowerPoints.append(point)
        }
        // upper points
        for point in flattenPoints.reversed() {
            while upperPoints.count >= 2 {
                let last = upperPoints.last!
                let preLast = upperPoints[upperPoints.count - 2]
                
                if getCrossProduct(o: preLast, a: last, b: point) > 0 {
                    break
                }
                upperPoints.removeLast()
            }
            upperPoints.append(point)

        }
        // removing duplicates
        upperPoints.removeLast()
        lowerPoints.removeLast()
        
        return ConvexPolygon(points: lowerPoints + upperPoints)
    }
    
    /**
     2D cross product of OA and OB (vectors), meaning z component of their 3D cross product
     
     - parameter o: first point to use
     - parameter a: second point to use
     - parameter b: the point to connect to o,a to get the curve
     - returns: the z component of the cross product of the vectors: a-o and b-o when the z value is set to 0
     */
    func getCrossProduct(o: (Int, Int), a: (Int, Int), b: (Int, Int)) -> Float {
        let oVec = GLKVector3(v: (Float(o.0), Float(o.1), 0))
        let aVec = GLKVector3(v: (Float(a.0), Float(a.1), 0))
        let bVec = GLKVector3(v: (Float(b.0), Float(b.1), 0))
        return GLKVector3CrossProduct(GLKVector3Subtract(aVec, oVec),
                                      GLKVector3Subtract(bVec, oVec)).v.2
        // aka: return (a.0 - o.0) * (b.1 - o.1) - (a.1 - o.1) * (b.0 - o.0)
    }
}

// MARK: - Convex Polygon Struct
struct ConvexPolygon {
    /// the points that represents the polygon
    var points: [(Int, Int)]
    
    /**
     init self with the given points
     Precondition: the point belong to a convex polygon, meaning all interior angles are less than or equal to 180 degrees
     
     - parameter points: the points to set to self
     */
    init(points: [(Int, Int)]) {
        self.points = points
    }
}
