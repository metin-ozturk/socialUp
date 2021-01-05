//
//  WhenToDoCalendarCell.swift
//  socialUp
//
//  Created by Metin Öztürk on 15.12.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

class WhenToDoCalendarCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dayLabel.backgroundColor = .darkGray
    }

}
