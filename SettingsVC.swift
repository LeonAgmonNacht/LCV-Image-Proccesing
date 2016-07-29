//
//  SettingsVC.swift
//  LCV
//
//  Created by לאון אגמון נכט on 01/07/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet var lowerRed: UISlider!
    @IBOutlet var lowerGreen: UISlider!
    @IBOutlet var lowerBlue: UISlider!
    @IBOutlet var upperRed: UISlider!
    @IBOutlet var upperGreen: UISlider!
    @IBOutlet var upperBlue: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // setting start values
        
        let values = [DataManager.sharedInstance.lowerRed,
                      DataManager.sharedInstance.lowerGreen,
                      DataManager.sharedInstance.lowerBlue,
                      DataManager.sharedInstance.upperRed,
                      DataManager.sharedInstance.upperGreen,
                      DataManager.sharedInstance.upperBlue]
        print("values: " + String(values))
        let sliders = [lowerRed,
                       lowerGreen,
                       lowerBlue,
                       upperRed,
                       upperGreen,
                       upperBlue]
        
        for i in 0...values.count-1 {
            sliders[i]?.setValue(Float(values[i]), animated: false)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // lower bound
    
    @IBAction func lowerRed(_ sender: AnyObject) {
        DataManager.sharedInstance.lowerRed = UInt8((sender as! UISlider).value)
   
    }
    
    @IBAction func lowerGreen(_ sender: AnyObject) {
        DataManager.sharedInstance.lowerGreen = UInt8((sender as! UISlider).value)

    }
    
    @IBAction func lowerBlue(_ sender: AnyObject) {
        DataManager.sharedInstance.lowerBlue = UInt8((sender as! UISlider).value)

    }
    
    // upper bound
    
    @IBAction func upperRed(_ sender: AnyObject) {
        DataManager.sharedInstance.upperRed = UInt8((sender as! UISlider).value)

    }
    
    @IBAction func upperGreen(_ sender: AnyObject) {
        DataManager.sharedInstance.upperGreen = UInt8((sender as! UISlider).value)

    }
    
    @IBAction func upperBlue(_ sender: AnyObject) {
        DataManager.sharedInstance.upperBlue = UInt8((sender as! UISlider).value)

    }
}
