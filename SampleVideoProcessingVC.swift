//
//  SampleVideoProcessingVC.swift
//  LCV
//
//  Created by לאון אגמון נכט on 11/06/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import UIKit
import AVFoundation
class SampleVideoProcessingVC: UIViewController {
    
    let previewSize = CGSize(width: 352/2, height: 288/2)
    let previewYPadding: CGFloat = 25
    
    var upperThreshValues: (UInt8, UInt8, UInt8) = (0,0,0)
    var lowerThreshValues: (UInt8, UInt8, UInt8) = (0,0,0)
    
    var timer: Timer?
    var cam: VideoCapture?
    
    @IBOutlet var displayImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCamera()
        
        // setting capture timer
        timer = Timer.scheduledTimer(timeInterval: 0.075, target: self, selector: #selector(SampleVideoProcessingVC.getAndProcessImage), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setThresholdValues()
    }
    
    func setThresholdValues() {
        
        upperThreshValues = (DataManager.sharedInstance.upperRed,
                                DataManager.sharedInstance.upperGreen,
                                DataManager.sharedInstance.upperBlue)
        lowerThreshValues = (DataManager.sharedInstance.lowerRed,
                                DataManager.sharedInstance.lowerGreen,
                                DataManager.sharedInstance.lowerBlue)

    }
    
    func setCamera() {
        let previewView = UIView(frame: CGRect(x:
            0,
            y: previewYPadding,
            width: previewSize.width,
            height: previewSize.height))
        self.view.addSubview(previewView)
        
        cam = VideoCapture(framePreset: AVCaptureSessionPreset352x288, onView: previewView)
    }
    
    func getAndProcessImage() {
        if cam!.canCapture() {
            cam!.getImageDataWithComplition(complition: { (data, error) in
                
                if error == nil && data != nil {
                    let capturedImage = UIImage(data: data!)
                    let imageToProc = ColorImage(image: capturedImage!)!
                    
                    
                    let binaryOutput = imageToProc.thresholdWithColorBounds(lower: self.lowerThreshValues, upper: self.upperThreshValues)
                    
                    let contours = binaryOutput.detectContours()
                    let biggestContour = contours.max { (con1, con2) -> Bool in
                        return con1.size < con2.size
                    }
                    
                    let resultImage = binaryOutput.toColorImage()!
                    
                    if biggestContour != nil {
                        let convexPoints = biggestContour?.convexHull()
                        let boundingBox = convexPoints?.getMinEnclosingRect()
                        let boudingRectangle = biggestContour?.getBoundingRectangle()
                        
                        RectangleDrawing.drawRectangle(image: resultImage,
                                                       rect: boudingRectangle!,
                                                       color: (255,0,0))
                        RectangleDrawing.drawRectangle(image: resultImage,
                                                       rect: boundingBox!,
                                                       color: (0,255,255))
                    }
                    self.displayImage.image = resultImage.toUIImage()

                }
                else {
                    print(error)
                    //fatalError()
                }
            })
        }
    }
}
