//
//  ViewController.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 01/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    //Core motion and timer initialization.
    let motion = CMMotionManager()
    var timer: Timer!
    let THRESHOLD = 0.4;
    
    // MARK: Properties
    // Accelerometer Data
    @IBOutlet weak var aLabelX: UILabel!
    @IBOutlet weak var aLabelY: UILabel!
    @IBOutlet weak var aLabelZ: UILabel!
    
    
    // Gyroscope Reading
    @IBOutlet weak var gLabelX: UILabel!
    @IBOutlet weak var gLabelY: UILabel!
    @IBOutlet weak var gLabelZ: UILabel!
    
    @IBOutlet weak var activityLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.monitorActivity();
    }
    
    func monitorActivity() {
        let activityManager = CMMotionActivityManager()
        
        activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: {(activity: CMMotionActivity!) -> Void in
            if(activity.walking == true) {
                self.activityLabel.text = "walking"
                //Start tracking accelerometer data.
                self.startAccelerometers()
            }
            if(activity.automotive == true) {
                //Start tracking data once detected driving..
                self.startAccelerometers()
                self.activityLabel.text = "driving";
            }
        })
    }
    
    
    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        if self.motion.isDeviceMotionAvailable {
            self.motion.showsDeviceMovementDisplay = true

            self.motion.deviceMotionUpdateInterval = 1.0 / 60.0  // 60 Hz
            self.motion.startDeviceMotionUpdates(
                using: .xMagneticNorthZVertical, to: .main, withHandler: { (data, error) in
                if let data = self.motion.deviceMotion {
                    // Use the motion data in your app.
                    if data.userAcceleration.x < -1.0 || data.userAcceleration.y < -1.0 {
                        print("detected movement..")
                        print(data.userAcceleration)
                        print(data.gravity)
                        if(data.userAcceleration.z < self.THRESHOLD) {
                            //invoke speech recognition algorithm.
                        }
                    }
                }
            })
        }
    }
    
    private func roundDouble(value: Double) -> Double {
        return round(1000 * value)/100
    }


}

