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
    var timer: Timer?
    var cam: VideoCapture?
    
    @IBOutlet var displayImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCamera()
        // setting capture timer
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(SampleVideoProcessingVC.getAndProcessImage), userInfo: nil, repeats: true)
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
                if error == nil {
                    let imageToProc = ColorImage(image: UIImage(data: data)!)!
                    let binaryOutput = imageToProc.thresholdWithColorBounds(lower: (0, 80, 0), upper: (100, 255, 100))
                    
                    let contours = binaryOutput.detectContours()
                    let biggestContour = contours.max { (con1, con2) -> Bool in
                        return con1.size < con2.size
                    }
                    
                    if biggestContour != nil {
                        let convexPoints = biggestContour?.convexHull()
                        let boundingBox = convexPoints?.getMinEnclosingRect()
                        let boudingRectangle = biggestContour!.getBoundingRectangle()
                        
                        RectangleDrawing.drawRectangle(image: imageToProc, rect: boudingRectangle, color: (0,0,0))
                        RectangleDrawing.drawRectangle(image: imageToProc, rect: boundingBox!, color: (255,255,255))
                        
                        self.displayImage.image = imageToProc.toUIImage()
                    }
                }
                else {
                    print(error)
                    fatalError()
                }
            })
        }
    }
}
