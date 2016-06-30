//
//  ImageRepClasses.swift
//  VisionMacApp
//
//  Created by לאון אגמון נכט on 30/04/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import UIKit
/**
 a struct that represents a pixel using red green blue alpha
 */
struct ColorPixel {
    /// the bits holding the pixel data
    private var value: UInt32 {
        didSet{
            /**
             shifting to the needed location and preforming an AND operator with 8 1s to get the wanted data
             */
            red = UInt8(value & 0xFF)
            green = UInt8((value >> 8) & 0xFF)
            blue = UInt8((value >> 16) & 0xFF)
            alpha = UInt8((value >> 24) & 0xFF)
        }
    }
    /// the red value of the pixel
    var red: UInt8 {
        didSet { value = UInt32(red) | (value & 0xFFFFFF00) }
    }
    /// the green value of the pixel
    var green: UInt8 {
        didSet { value = (UInt32(green) << 8) | (value & 0xFFFF00FF) }
    }
    /// the blue value of the pixel
    var blue: UInt8 {
        didSet { value = (UInt32(blue) << 16) | (value & 0xFF00FFFF) }
    }
    /// the alpha value of the pixel
    var alpha: UInt8 {
        didSet { value = (UInt32(alpha) << 24) | (value & 0x00FFFFFF) }
    }
    /**
     initializing a ColorPixel instance using the given red(r) green(g) blur(b) alpha(a) values
     - parameter r: the red value of the pixel
     - parameter g: the green value of the pixel
     - parameter b: the blue value of the pixel
     - parameter a: the alpha value of the pixel
     
     */
    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        red = r
        green = g
        blue = b
        alpha = a
        value = (UInt32(red)) | (UInt32(green) << 8) | (UInt32(blue) << 16) | (UInt32(alpha)  << 24)
    }
    /**
     is self between the given RGB values
    - parameter lower: the lower bound to use, a tuple represeting the (red, green, blue) values for the lower threshold
    - parameter upper: the upper bound to use, a tuple represeting the (red, green, blue) values for the upper threshold
    - returns: true if and only if:
     - lower.0 <= self.red <= upper.0
     - lower.1 <= self.green <= upper.1
     - lower.2 <= self.blue <= upper.2

     */
    func isInBoundes(lower: (UInt8, UInt8, UInt8), upper: (UInt8, UInt8, UInt8)) -> Bool {
        if self.red >= lower.0 && self.red <= upper.0 {
            if self.green >= lower.1 && self.green <= upper.1 {
                if self.blue >= lower.2 && self.blue <= upper.2 {
                    return true
                }
            }
        }
        return false
    }
}
/**
 a class that represents an ColorImage image using an UnsafeMutableBufferPointer of ColorPixel
 */
class ColorImage: NSObject {
    /// the pixels of the image represented in self
    var pixels: UnsafeMutableBufferPointer<ColorPixel>
    /// the width of the image represented in self
    var width: Int
    /// the height of the image represented in self
    var height: Int
    
    // MARK: - Constants
    /// the number of bits in a component(aka: red, green, blue, alpha)
    let bitsPerComponent = 8
    /// the number of bytes in a pixel (the number of components in a pixel)
    let bytesPerPixel = 4
    /// the bitmap info taken from the UIImage the instance was init with
    var bitmapInfo: UInt32
    
    // MARK: - Initializers
    
    /**
     initializing a ColorImage class instance using a NSImage
     
     - parameter image: the image to get the pixels from
     */
    init?(image: UIImage) {
        // geting the bitmap image of image with the above frame
        guard let cgImage = image.cgImage else { return nil }
        
        width = Int(image.size.width)
        height = Int(image.size.height)
        
        // setting image properties:
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // allocating the needed space for the image
        let imageData = UnsafeMutablePointer<ColorPixel>.init(allocatingCapacity: width * height)
        
        // creating the info for the pixels bitmap(e.g we want the alpha in the last 8 bytes, and we want an alpha value)
        bitmapInfo = cgImage.bitmapInfo.rawValue
        // setting the data to the imageData
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        
        imageContext.draw(in: CGRect(origin: CGPoint.zero, size: image.size), image: cgImage)
        pixels = UnsafeMutableBufferPointer<ColorPixel>(start: imageData, count: width * height)
        
    }
    
    deinit {
        pixels.baseAddress?.deinitialize(count: pixels.count)
        pixels.baseAddress?.deallocateCapacity(pixels.count)
    }
    
    // MARK: - Methods
    
    /**
     calculates and returns the UIImage representation of self, needed mostly to display
     
     - returns: a UIImage holding the data in self
     */
    func toUIImage() -> UIImage? {
        
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // creating the info for the pixels bitmap(e.g we want the alpha in the last 8 bytes, and we want an alpha value)
        let imageContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        guard let cgImage = imageContext?.makeImage() else {return nil}
        return UIImage(cgImage: cgImage)
    }
    /**
     returns/set the pixel in the index (row, col) = indexes
     
     - returns: a ColorPixel in the position (row, col) = indexes
     */
    subscript(indexes: (Int,Int)) -> ColorPixel {
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
}
