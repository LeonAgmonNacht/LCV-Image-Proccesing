//
//  ContoursClasses.swift
//  VisionMacApp
//
//  Created by לאון אגמון נכט on 30/05/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import Foundation

/**
 a struct represeting a contour using its points
 */
struct Contour {
    /// the points of the contour in the format [(row, col)], each element is all the points that has the same row value. both the inner and the outer arrays are sorted ascnending
    var points: [[(Int, Int)]]
    /// the number of points in the contour. size == getPoints.flatten().count
    var size: Int
    
    /**
     initializing an empty contour
     */
    init() {
        points = []
        size = 0
    }
    
    func getPoints() -> [[(Int, Int)]] {
        return points
    }
    /**
     adds a new point to self
     - parameter point: the point to add to self
     */
    mutating func addPoint(point: (Int, Int)) {
        let proposedInsertionIndex = points.binarySearch(predicate: {$0[0].0 < point.0}) // the row to add the point
        if proposedInsertionIndex != points.count && points[proposedInsertionIndex][0].0 == point.0 { // already exists
            let positionInArray = points[proposedInsertionIndex ].binarySearch(predicate: {$0.1 < point.1}) // the index of the new point in the found already existing array searched using the column number
            points[proposedInsertionIndex].insert(point, at: positionInArray)
        }
        else { // new point, no array of points has the same row number as point
            points.insert([point], at: proposedInsertionIndex)
        }
        
        size += 1
    }
    /**
     returns all the points between the points of the contour
     
     - returns: the points (row, col) that has a point in self.points that have a smaller row number, and a point in self.points that has a greator row number
     */
    func getArea() -> [(Int, Int)] {
        var result: [(Int, Int)] = []
        for pointsGroup in points {
            for i in 0..<pointsGroup.count/2 {
                let firstPoint = pointsGroup[i*2]
                let secondPoint = pointsGroup[i*2 + 1]
                for diff in firstPoint.1 ... secondPoint.1 {
                    result.append((firstPoint.0, diff))
                }
            }
            if pointsGroup.count % 2 != 0 {
                result.append(pointsGroup.last!)
            }
        }
        return result
    }
    
}
// MARK: - Binary Search
extension Collection where Index: Strideable {
    /**
     returns the index of the last element that return true for the predicate, this method uses binary search therefor self should be sorted!
     - parameter predicate: the predicate to use to find the wanted index
     - returns: the index of the first element that doesn't return true
     */
    func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
            if predicate(self[mid]) {
                low = index(mid, offsetBy: 1)
            } else {
                high = mid
            }
        }
        return low
    }
}
