//
//  ColorImageMethods.swift
//  VisionMacApp
//
//  Created by לאון אגמון נכט on 01/05/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import Foundation

// MARK: - Image Filttering

extension ColorImage {
    /**
     filters self using the given RGB color bounds.
     a pixel in the color image will be white in the returned binary image if and only if:
     - lower.0 <= pixel.red <= upper.0
     - lower.1 <= pixel.green <= upper.1
     - lower.2 <= pixel.blue <= upper.2
     - parameter lower: the lower bound to use, a tuple represeting the (red, green, blue) values for the lower threshold
     - parameter upper: the upper bound to use, a tuple represeting the (red, green, blue) values for the upper threshold
     - returns: a thresholded binary image using the given color bounds
     */
    func thresholdWithColorBounds(lower: (UInt8, UInt8, UInt8), upper: (UInt8, UInt8, UInt8)) -> BinaryImage {
        let resultImage = BinaryImage(width: self.width, height: self.height)
        for row in 0..<height {
            for col in 0..<width {
                resultImage[(row,col)] = self[(row,col)].isInBoundes(lower: lower, upper: upper)
            }
        }
        return resultImage
    }
}
