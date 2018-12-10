//
//  NeighborhoodScoreViewController.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 06/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class NeighborhoodScoreViewController: UITableViewController, CLLocationManagerDelegate {

    var potholes: [PotHoleRanking] = []
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self as? CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
    }
    
    //MARK: CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.getPotHoles(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude);
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK: Activity Indicator
    func startLoading(){
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.style = UIActivityIndicatorView.Style.gray;
        view.addSubview(activityIndicator);
        
        activityIndicator.startAnimating();
        UIApplication.shared.beginIgnoringInteractionEvents();
        
    }
    
    func stopLoading(){
        activityIndicator.stopAnimating();
        UIApplication.shared.endIgnoringInteractionEvents();
        
    }
    
    //MARK: TableView delegate functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return potholes.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NeighborhoodScoreTableViewCell") as! NeighborhoodScoreTableViewCell
        // Fetches the appropriate meal for the data source layout.
        let pothole = self.potholes[indexPath.row]
        
        cell.neighborHoodLabel.text = pothole.neighborhood
        cell.potholeCountLabel.text = String(pothole.potholeCount)

        return cell
    }
    
    /*
     * Navigate to detailed neighborhood view controller.
    */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let potholeRanking = self.potholes[indexPath.row]
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let neighborHoodDetailedView = mainStoryboard.instantiateViewController(withIdentifier: "NeighborhoodDetailViewController") as! NeighborhoodDetailViewController
        neighborHoodDetailedView.title = potholeRanking.neighborhood
        neighborHoodDetailedView.potHoleRanking = potholeRanking
        self.navigationController?.pushViewController(neighborHoodDetailedView, animated: true)
    }
    
    /**
     * Retrieve pothole from api endpoint.
     **/
    private func getPotHoles(latitude: Double, longitude: Double) {
        self.startLoading();
//        let url : String = "https://bmy2u2cwc4.execute-api.us-west-1.amazonaws.com/beta/pothole/ranking"
        var components = URLComponents()
        components.scheme = "https"
        components.host = "bmy2u2cwc4.execute-api.us-west-1.amazonaws.com"
        components.path = "/beta/pothole/ranking"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
        ]
        
        let url = components.url
        
        print(url);
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request){(data, response, error) in
            // completion handler block
            if (error != nil) {
                print(error!)
            } else {
                if let data = data {
                    guard let potholes = try? JSONDecoder().decode([PotHoleRanking].self, from: data) else {
                        print("Error couldnt decode")
                        return
                    }
                    for pothole in potholes {
                        self.potholes.append(pothole)
                    }
                    
                    DispatchQueue.main.async {
                        self.stopLoading()
                        self.tableView.reloadData()
                    }
                }
            }
        }
        task.resume()
    }
}
