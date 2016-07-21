//
//  VideoCapture.swift
//  LCV
//
//  Created by לאון אגמון נכט on 11/06/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

/**
 a class represents a vdeo camera and hendles the capture of frames
 */
class VideoCapture {
    /// the device to be used to get frames from, camera.hasMediaType(AVMediaTypeVideo) == true always
    private var camera: AVCaptureDevice
    /// the capture session that holds the settings and has access to the camera video
    private var captureSession: AVCaptureSession = AVCaptureSession()
    /// the output linked to the session to get the still image from
    private var stillImageOutput: AVCaptureStillImageOutput = AVCaptureStillImageOutput()
    
    /**
     constructs a new VideoCapture instance
     - parameter deviceIndex: the index in the array of devices (AVCaptureDevice.devices()) to be used as the camera, defult to -1, the first device that supports video
     - prameter framePreset: the preset to define to the images returns from the camera
     - parameter view: the view to add the preview for, must be used according to apple
     */
    init(deviceIndex: Int = -1, framePreset: String, onView view: UIView) {
        // setting defult values that will be overwriten
        camera = VideoCapture.getCamera(deviceIndex: deviceIndex)
        setCaptureSession(framePreset: framePreset)
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.connection.videoOrientation = .portrait
        view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = view.layer.frame
        captureSession.startRunning()
    }
    /**
     - parameter deviceIndex: the index in the array of devices (AVCaptureDevice.devices()) to be used as the camera, if -1 the first device that supports video
     - returns the camera device generated using the given device index
     */
    private static func getCamera(deviceIndex: Int) -> AVCaptureDevice {
        if deviceIndex != -1 {
            let tempCamera = AVCaptureDevice.devices()[deviceIndex] as! AVCaptureDevice
            if !tempCamera.hasMediaType(AVMediaTypeVideo) {
                fatalError("Given device is not a video device, exiting!!!")
            }
            print("Camera is: \(tempCamera)")
            return tempCamera
        }
        else {
            let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            if devices?.count == 0 {
                fatalError("No video device found, exiting!!!")
                
            }
            let tempCamera = devices?[0] as! AVCaptureDevice
            print("Camera is: \(tempCamera)")
            return tempCamera
        }
    }
    /**
     setting the capture session using the given frame preset
     Precondition: the camera ivar is set
     - prameter framePreset: the preset to define to the images returns from the camera
     */
    private func setCaptureSession(framePreset: String) {
        do {
            try camera.lockForConfiguration()
            // add code to control auto focus exposure and etc
            camera.unlockForConfiguration()
            if captureSession.canSetSessionPreset(framePreset) {
                captureSession.sessionPreset = framePreset
            }
            else {
                print("Unable to set preset, not supported by camera")
            }
            
            // set input
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            else {
                print("Unable to set input")
            }
            
            // set output
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            else {
                print("Unable to set output")
            }
            
            
        } catch {
            fatalError("Unable to configure device, exiting!!!")
        }
    }
    /**
     captures a still image from the camera
     - parameter complition: a closure to execute after the new image recieved, the closure holds the data of the image
     */
    func getImageDataWithComplition(complition: ((Data?, NSError?) -> Void)) {
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                
                if error != nil {
                    complition(nil, error)
                    return
                }
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                complition(imageData, error)
            }
        }
        else {
            print("Unable to capture still image")
        }
    }
    /**
     - returns: true iff not in the middle of capturing image
     */
    func canCapture() -> Bool {
        return !stillImageOutput.isCapturingStillImage
    }
}
