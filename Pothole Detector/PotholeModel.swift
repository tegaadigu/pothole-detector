//
//  PotholeModel.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 04/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import Foundation

struct PotholeModel: Decodable {
    let lat: Double
    let lon: Double
    let user_id: Int
    let created_on: String
    let id: Int
}
