//
//  BinaryImageUtils.swift
//  VisionMacApp
//
//  Created by לאון אגמון נכט on 02/05/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import Foundation

// MARK: - Detect Contours

extension BinaryImage {
    
    /**
     detects the contours in self, a contur is a set of points that are the outer border of a white object in self
     This method uses the Theo Pavlidis algrorithem
     - returns: an array of the found contours
     */
    func detectContours() -> [Contour] {
        var result: [Contour] = []
        // a copy of self to modify in the contour detection
        let copy = self.clone()
        for row in 0..<self.height {
            for col in 0..<self.width {
                if copy[row, col] { // white
                    if let newContour = copy.detectContourTheoPavlidis(startPoint: (row, col)) {
                        result.append(newContour)
                        for point in newContour.getArea() {
                            copy[point] = false
                        }
                    }
                }
            }
        }
        return result
    }
    
    /**
     detects the contour from the start point startPoint 
     
     - parameter startPoint: the start point to start the search for
     - returns: the detected contour iff for all point in the points of the contour the point has a neihbor in 3X3 connectivity, else nil. (therefore a single pixel will not be detected).
     */
    private func detectContourTheoPavlidis(startPoint: (Int, Int)) -> Contour? {
        var resultContour = Contour()
        resultContour.addPoint(point: startPoint)
        var dir = 0
        var lastPoint = startPoint
        while true {
            if let nextNeighbor = detectNextNeighborTheoPavlidis(point: lastPoint, dir: dir){
                let nextPoint = nextNeighbor.0
                if nextPoint != startPoint {
                    // changing self so we don't detect this point in other contours
                    self[nextPoint] = false
                    lastPoint = nextPoint
                    resultContour.addPoint(point: nextPoint)
                    dir = nextNeighbor.1
                }
                else {
                    return resultContour
                }
            }
            else {
                return nil
            }
        }
    }
    /**
     detects the next neighbor(white pixel in 3X3 connectivity) starting in point point and the direction dir.
     Uses the Theo Pavlidis algorithem
     - parameter point: the start point to start the search in
     - parameter dir: the start direction to search the next neighbor at
     - returns: the detected neighbor (Int ,Int) = (row, col) and the direction the search ended at
     */
    private func detectNextNeighborTheoPavlidis(point: (Int, Int), dir: Int) -> ((Int, Int), Int)? {
        let functions = [checkNextButton, checkNextRight, checkNextForward, checkNextLeft]
        for rotation in 0...3 {
            let shiftedDir = (dir + rotation) % 4
            if let neighbor = functions[shiftedDir](point: point) {
                return (neighbor, shiftedDir - 1 >= 0 ? shiftedDir - 1: 3)
            }
        }
        return nil
    }
    /**
     checking if one of the three neighbors in front(the given direction) is white, if true returns the location of the found pixel, nil if no one of the pixels is white
     
     - parameter point: the start point to start the search in
     - parameter direction: the start direction to search the next neighbor at
     - parameter startOffset: the offset to give the point point before starting to search
     - returns: the found nighbor(white pixel) if found else nil
     */
    func checkNext(point: (Int, Int), startOffset: (Int, Int), direction: (Int, Int)) -> (Int, Int)? {
        let shiftedPoint = point + startOffset
        for i in -1 ... 1 {
            let neighbor = shiftedPoint + (direction*i)
            if self.isValidIndexForPixel(index: neighbor) && self[neighbor] { // white
                return neighbor
            }
        }
        return nil
    }
    
    // MARK: - Check Directions
    
    private func checkNextButton(point: (Int, Int)) -> (Int, Int)? {
        return checkNext(point: point, startOffset: (1, 0), direction: (0, 1))
    }
    private func checkNextLeft(point: (Int, Int)) -> (Int, Int)? {
        return checkNext(point: point, startOffset: (0, -1), direction: (1, 0))
    }
    private func checkNextForward(point: (Int, Int)) -> (Int, Int)? {
        return checkNext(point: point, startOffset: (-1, 0), direction: (0, -1))
    }
    private func checkNextRight(point: (Int, Int)) -> (Int, Int)? {
        return checkNext(point: point, startOffset: (0, 1), direction: (-1, 0))
    }
}
