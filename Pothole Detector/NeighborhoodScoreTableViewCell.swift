//
//  NeighborhoodScoreTableViewCell.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 06/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import UIKit

class NeighborhoodScoreTableViewCell: UITableViewCell {
    // MARK: Property
    @IBOutlet weak var neighborHoodLabel: UILabel!
    @IBOutlet weak var potholeCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
