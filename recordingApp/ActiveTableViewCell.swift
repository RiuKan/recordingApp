//
//  ActiveTableViewCell.swift
//  recordingApp
//
//  Created by 류강 on 23/01/2020.
//  Copyright © 2020 류강. All rights reserved.
//

import UIKit

class ActiveTableViewCell: UITableViewCell {
    
    @IBOutlet weak var waitName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
