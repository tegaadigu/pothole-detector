//
//  PotHoleRankingModel.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 09/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import Foundation


struct PotHoleRanking: Decodable {
    let neighborhood: String
    let potholeCount: Int
    let userList: [UserList]
    let potholes: [PotHole]
}

//Model for pothole location.
struct PotHole: Decodable {
    let lat: Double
    let lon: Double
    let name: String
}
