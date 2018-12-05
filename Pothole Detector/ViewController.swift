//
//  ViewController.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 01/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import UIKit
import CoreMotion
import MapKit
import CoreLocation
import Speech

class ViewController: UIViewController, CLLocationManagerDelegate, SFSpeechRecognizerDelegate {
    //Core motion and timer initialization.
    let motion = CMMotionManager()
    var timer: Timer!
    let THRESHOLD = 0.4;
    
    
    // MARK: Properties
    // Map View
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    // Speech Recognition
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
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

        // set initial location in Honolulu
        self.mapView.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }else {
            print("gps not on.")
        }
        
        self.monitorActivity();
        //Get all potholes from endpoint
        self.getPotHoles();
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
        
        self.startAccelerometers()
    }
    
    
    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        if self.motion.isDeviceMotionAvailable {
            self.motion.showsDeviceMovementDisplay = true

            self.motion.deviceMotionUpdateInterval = 2.0  // 60 Hz
            self.motion.startDeviceMotionUpdates(
                using: .xMagneticNorthZVertical, to: .main, withHandler: { (data, error) in
                if let data = self.motion.deviceMotion {
                    self.aLabelX.text = String(data.userAcceleration.x)
                    self.aLabelY.text = String(data.userAcceleration.y)
                    self.aLabelZ.text = String(data.userAcceleration.z)
                    // Use the motion data in your app.
                    if data.userAcceleration.x < -1.0 || data.userAcceleration.y < -1.0 {
//                        print("detected movement..")
//                        print(data.userAcceleration)
//                        print(data.gravity)
                        if(data.userAcceleration.z < self.THRESHOLD) {
                            //invoke speech recognition algorithm.
                            self.recordAndRecognizeSpeech()
//                            print("found Z is less than threshold")
                        }
                    }
                }
            })
        }
    }
    
    private func roundDouble(value: Double) -> Double {
        return round(1000 * value)/100
    }
    
    private func updatePotholesInMap(potholes: [PotholeModel]) {
        for pothole in potholes {
            let CLLCoordType = CLLocationCoordinate2D(latitude: pothole.lat, longitude: pothole.lon);
            let anno = MKPointAnnotation();
            anno.coordinate = CLLCoordType;
            self.mapView.addAnnotation(anno);
        }
    }
    
    private func getPotHoles() {
        let url : String = "https://bmy2u2cwc4.execute-api.us-west-1.amazonaws.com/beta/pothole"
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: URL(string: url)!)
        let task = session.dataTask(with: request){(data, response, error) in
            // completion handler block
            if (error != nil) {
                print(error!)
            } else {
                if let data = data {
                    guard let potholes = try? JSONDecoder().decode([PotholeModel].self, from: data) else {
                        print("Error couldnt decode")
                        return
                    }
                    self.updatePotholesInMap(potholes: potholes);
                }
            }
        }
        task.resume()
    }

    //MARK: CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations);
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK: Speech Recognition function
    
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest.append(buffer);
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }catch {
            return print(error)
        }
        
        guard let audioRecognizer = SFSpeechRecognizer() else {
            print("Recognizer not supported")
            return;
        }
        
        if !audioRecognizer.isAvailable {
            print("Recognizer not available")
            return
        }
        
        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result: SFSpeechRecognitionResult?, error: Error?) in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
//                print("best String: "+bestString)
                
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString.substring(from: indexTo)
                }
                self.checkForSaidCommand(resultString: lastString)
                
            }else if let error = error {
                print(error)
            }
        })
        
    }
    
    func checkForSaidCommand(resultString: String) {
        print("result: " + resultString)
    }


}

