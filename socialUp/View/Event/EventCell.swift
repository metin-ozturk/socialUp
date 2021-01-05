//
//  EventCell.swift
//  socialUp
//
//  Created by Metin Öztürk on 14.12.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateVoteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
