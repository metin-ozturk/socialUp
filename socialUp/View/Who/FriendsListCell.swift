//
//  FriendsListCell.swift
//  socialUp
//
//  Created by Metin Öztürk on 15.12.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

class FriendsListCell: UITableViewCell {
    @IBOutlet weak var friendProfileImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendProfileImageViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
