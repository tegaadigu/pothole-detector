//
//  NeighborhoodDetailViewController.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 09/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import UIKit
import MapKit

class NeighborhoodDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    var potHoleRanking: PotHoleRanking!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        self.updatePotholesInMap(potholes: self.potHoleRanking.potholes)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.potHoleRanking.userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let userList = self.potHoleRanking.userList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingUserTableViewCell") as! RankingUserTableViewCell
        cell.userNameLabel.text = userList.name
        cell.potholeCountLabel.text = String(userList.potholeCount)+" Pothole Reported"
        
        return cell
    }
    
    private func updatePotholesInMap(potholes: [PotHole]) {
        for pothole in potholes {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: pothole.lat, longitude: pothole.lon), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            
            self.mapView.setRegion(region, animated: true)

            let CLLCoordType = CLLocationCoordinate2D(latitude: pothole.lat, longitude: pothole.lon);
            let anno = MKPointAnnotation();
            anno.coordinate = CLLCoordType;
            self.mapView.addAnnotation(anno);
        }
    }
}
