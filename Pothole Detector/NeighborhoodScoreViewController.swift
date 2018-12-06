//
//  NeighborhoodScoreViewController.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 06/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import UIKit

class NeighborhoodScoreViewController: UITableViewController {

    var potholes: [PotHoleRanking] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPotHoles();
        // Do any additional setup after loading the view.
    }
    
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
    
    private func getPotHoles() {
        let url : String = "https://bmy2u2cwc4.execute-api.us-west-1.amazonaws.com/beta/pothole/ranking"
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: URL(string: url)!)
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
                    print(potholes);
                    for pothole in potholes {
                        self.potholes.append(pothole)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        task.resume()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
