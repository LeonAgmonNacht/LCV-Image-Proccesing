//
//  CalculationsHelper.swift
//  LCV
//
//  Created by לאון אגמון נכט on 27/07/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import Foundation

/**
 a class to hold all needed mathematical calculations
 */
class CalculationsHelper {
    
    /// the constant to mult the offset for the azimuth angle
    static let azimuthOffsetConstant: Float = 0.7
    
    /**
     calculates the azimuth angle after correcting the skew corruption
     - parameter viewingAngle: the viewing angle of the image the rotatedRectangle was extracted from
     - parameter width: the width in pixels of the image the rotatedRect was extracted from
     - prameter rotatedRect: the rotated rectangle to calculate the azimuth angle from its center to the
     - returns: the azimuth angle calculated
     */
    static func getAzimuthaAngle(viewingAngle: Float, width: Float, rotatedRect: RotatedRectangle) -> Float {
        var correctedAngle: Float = 0.0
        if rotatedRect.angle < -45 {
            correctedAngle = rotatedRect.angle + 90
        }
        else if rotatedRect.angle > 45 {
            correctedAngle = rotatedRect.angle - 90
        }
        
        let offset = (correctedAngle / 90) * (width / 2)
        let correctedOffset = offset * azimuthOffsetConstant
        // get the angle from center of rotated rectangle to the center of the frame:
        let currectedWidth = rotatedRect.width + correctedOffset
        let rectCenter = currectedWidth / 2
        let corners = rotatedRect.getRectangleCorners()
        let cornersSortedX = corners.sorted { $0.0 < $1.0 }
        let leftCorners = [cornersSortedX[0], cornersSortedX[1]]
        let leftCornersSortedY = leftCorners.sorted { $0.1 > $1.1 }
        let xCoord = leftCornersSortedY[0].0
        
        return (((Float(xCoord) + rectCenter) / width) - 0.5) * viewingAngle
    }
}
