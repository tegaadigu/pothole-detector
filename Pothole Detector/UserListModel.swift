//
//  UserListModel.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 09/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import Foundation

struct UserList: Decodable {
    let id: Int
    let name: String
    let potholeCount: Int
}
