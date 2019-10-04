//
//  ResultsTableViewCell.swift
//  ocrTestApp
//
//  Created by Allison McEntire on 9/30/19.
//  Copyright © 2019 Allison McEntire. All rights reserved.
//

import UIKit

class ResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var resultsImageView: UIImageView!
    @IBOutlet weak var resultsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resultsLabel.sizeToFit()
        // Initialization code
    }

    
}
