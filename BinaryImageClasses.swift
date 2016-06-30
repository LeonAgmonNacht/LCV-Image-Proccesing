//
//  BinaryImageClasses.swift
//  VisionMacApp
//
//  Created by לאון אגמון נכט on 30/04/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import UIKit
/**
 a class that represents a binary image
 */
class BinaryImage: NSObject {
    /// the pixels of the image represented as a Bool value, true is white
    var pixels: UnsafeMutableBufferPointer<Bool>
    /// the width of the image represented in self
    var width: Int
    /// the height of the image represented in self
    var height: Int
    
    // MARK: - initializers
    
    /**
     initializing the class with the given size and value
     
     - parameter width: the width of the binary image
     - paramter height: the height of the binary image
     - parameter defultValue: the defult value true of false to give to all pixels in the image
     */
    init(width: Int, height: Int, defultValue: Bool = false) {
        self.width = width
        self.height = height
        let pointer = UnsafeMutablePointer<Bool>.init(allocatingCapacity: width*height)
        pixels = UnsafeMutableBufferPointer<Bool>(start: pointer, count: width*height)
        for i in 0..<height*width { // init the new memory
            pixels[i] = defultValue
        }
    }
    /**
     initializing the class with no data, height = 0, width = 0, pixels.count = 0
     */
    override init() {
        pixels = UnsafeMutableBufferPointer<Bool>(start: nil, count: 0)
        width = 0
        height = 0
    }
    
    deinit {
        pixels.baseAddress?.deinitialize(count: pixels.count)
        pixels.baseAddress?.deallocateCapacity(pixels.count)
    }
    
    // MARK: - methods
    
    /**
     calculates and returns the UIImage representation of self, needed mostly to display
     
     - returns: a UIImage holding the data in self
     */
    func toUIImage() -> UIImage? {
        // creating a black image
        let size = CGSize(width: width, height: height)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.black().setFill()
        UIRectFill(rect)
        let blackImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let colorImage = ColorImage(image: blackImage)
        for row in 0..<height {
            for col in 0..<width {
                let pixel = self[(row,col)]
                if pixel == true { // white
                    colorImage![(row, col)] = pixel.toColorPixel()
                }
            }
        }
        return colorImage?.toUIImage()
    }
    
    /**
     returns the pixel in the index (row, col) = indexes
     
     - returns: a Bool in the position (row, col) = indexes of the image
     */
    subscript(indexes: (Int,Int)) -> Bool {
        get {
            let pixelIndex = indexes.0 * width + indexes.1
            return pixels[pixelIndex]
        }
        set {
            let pixelIndex = indexes.0 * width + indexes.1
            pixels[pixelIndex] = newValue
        }
    }
    /**
     returns true if and only if the given index is valid
     - parameter index: (row, col) to check if valid for a pixel
     - returns true if and only if 0 <= index.0 < height && 0 <= index.1 < width
     */
    func isValidIndexForPixel(index: (Int, Int)) -> Bool {
        return index.0 < height && index.1 < width && index.0 >= 0 && index.1 >= 0
    }
    
    /**
     returns an instance of BinaryImage holding the date in self, width-height-pixels
     
     - returns: an instance of BinaryImage holding the data in self
     */
    func clone() -> BinaryImage {
        let clone = BinaryImage()
        clone.width = self.width
        clone.height = self.height
        clone.pixels = UnsafeMutableBufferPointer<Bool>.init(start: UnsafeMutablePointer<Bool>.init(allocatingCapacity: pixels.count), count: pixels.count)
        clone.pixels.baseAddress?.assignFrom(pixels.baseAddress!, count: pixels.count)
        return clone
    }
}

extension Bool {
    /**
     - returns: a ColorPixel representation of self, true is white pixel, false is a black pixel
     */
    func toColorPixel()-> ColorPixel {
        return ColorPixel(r: self ? 255 : 0, g: self ? 255 : 0, b: self ? 255 : 0, a: 255)
    }
}
