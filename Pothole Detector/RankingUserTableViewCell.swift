//
//  RankingUserTableViewCell.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 09/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import UIKit

class RankingUserTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var potholeCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
