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
import AVFoundation

class DashboardViewController: BaseViewController, CLLocationManagerDelegate, SFSpeechRecognizerDelegate {
    //Core motion and timer initialization.
    let motion = CMMotionManager()
    var timer: Timer!
    let THRESHOLD = 0.4;
    var stop = false;
    
    // MARK: Properties
    @IBOutlet weak var stopBtn: UIButton!
    
    // Audio Profiles
    var audioPlayer: AVAudioPlayer?
    
    // Map View
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var lastLocation = CLLocation();
    
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
        self.mapView.showsUserLocation = true
        // Do any additional setup after loading the view, typically from a nib.
        addSlideMenuButton()
        stopBtn.layer.cornerRadius = 10
        //Get all potholes from endpoint
        self.getPotHoles();
    }
    
    @IBAction func onStartStopToggle(_ sender: Any) {
        self.stop = !self.stop;
        if(self.stop) {
            self.stopBtn.setTitle("Start", for: .normal)
            self.motion.stopDeviceMotionUpdates();
        }else {
             self.stopBtn.setTitle("Stop", for: .normal)
            // start location service.
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
            // start monitoring activity.
            self.startAccelerometers()
//            self.monitorActivity();
        }
    }
    
    //Function to monitor user's activity if they are walking or driving.
    func monitorActivity() {
        let activityManager = CMMotionActivityManager()
        
        activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: {(activity: CMMotionActivity!) -> Void in
            if(activity.walking == true) {
//                self.activityLabel.text = "walking"
                //Start tracking accelerometer data.
                if(!self.stop) {
                    self.startAccelerometers()
                }
            }
            if(activity.automotive == true) {
                //Start tracking data once detected driving..
                if(!self.stop) {
                    self.startAccelerometers()
                }
//                self.activityLabel.text = "driving";
            }
        })
        
//        self.startAccelerometers()
    }
    
    
    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        if self.motion.isDeviceMotionAvailable {
            self.motion.showsDeviceMovementDisplay = true

            self.motion.deviceMotionUpdateInterval = 1.0 / 60  // 60 Hz
            self.motion.startDeviceMotionUpdates(
                using: .xMagneticNorthZVertical, to: .main, withHandler: { (data, error) in
                if let data = self.motion.deviceMotion {
                    // Use the motion data in your app.
                    if data.userAcceleration.x < -1.0 || data.userAcceleration.y < -1.0 {
                        print("ooh we found shake")
                        if(data.userAcceleration.z < self.THRESHOLD) {
                            self.potHoleDetected();
                        }
                    }
//                    self.aLabelX.text = String(data.userAcceleration.x)
//                    self.aLabelY.text = String(data.userAcceleration.y)
//                    self.aLabelZ.text = String(data.userAcceleration.z)
                }
            })
        }
    }
    
    private func potHoleDetected() {
        //Stop motion update once detected pothole.
        self.motion.stopDeviceMotionUpdates();
        self.locationManager.stopUpdatingLocation();

        // Play pothole detected
        do {
            if let fileURL = Bundle.main.path(forResource: "detectedPothole", ofType: "mp3") {
                print("Playing audio")
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                audioPlayer?.play();
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
        //activate speech recognition
        // Declare Alert message
        let dialogMessage = UIAlertController(title: "Pothole Detected!", message: "Save Pothole?", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            self.storePothole();
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
            self.stop = false;
            self.locationManager.startUpdatingLocation();
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
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
                    print(potholes)
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
        
        self.lastLocation = locations[0];
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
                print("best String: "+bestString)
                
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
    
    //MARK: Storing Pothole to api endpoint
    private func storePothole() {
        //store pothole to api endpoint
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "bmy2u2cwc4.execute-api.us-west-1.amazonaws.com"
        urlComponents.path = "/beta/pothole"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        // Specify this request as being a POST method
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Make sure that we include headers specifying that our request's HTTP body
        // will be JSON encoded
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        // Now let's encode out Post struct into JSON data...
        let encoder = JSONEncoder()
        let dataToPost = PostPothole(lat: self.lastLocation.coordinate.latitude, lon: self.lastLocation.coordinate.longitude, user_id: 1, created_on: "2018-12-06");
        do {
            let jsonData = try encoder.encode(dataToPost)
            // ... and set our request's HTTP body
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch {
            print("Couldnt encode to json")
        }
        
        // Create and run a URLSession data task with our JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                print("response error")
                return
            }
            
            // APIs usually respond with the data you just sent in your POST request
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
            } else {
                print("no readable data received in response")
            }
        }
        task.resume()
    }
}

