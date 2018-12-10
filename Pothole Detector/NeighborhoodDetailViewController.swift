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
        //self.updatePotholesInMap(userList: self.potHoleRanking.userList)
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
}
