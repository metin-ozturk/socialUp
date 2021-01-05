//
//  FriendsListCustomCell.swift
//  socialUp
//
//  Created by Metin Öztürk on 19.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

class FriendsListCustomCell : UITableViewCell {
    
    let friendProfileImageView : UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = UIImageView.ContentMode.scaleAspectFit
        return imageView
    }()
    
    let friendNameLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setFriendProfileImageView()
        setFriendNameLabel()
        
    }
    
    private func setFriendProfileImageView() {
        self.addSubview(friendProfileImageView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: friendProfileImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: friendProfileImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: friendProfileImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: friendProfileImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 0.2, constant: 0)
            ])
        
    }
    
    private func setFriendNameLabel() {
        self.addSubview(friendNameLabel)
            
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: friendNameLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: friendNameLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: friendNameLabel, attribute: .leading, relatedBy: .equal, toItem: friendProfileImageView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: friendNameLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class FriendsListCustomCellWithoutImage : FriendsListCustomCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        friendProfileImageView.removeFromSuperview()
        friendNameLabel.removeConstraints(friendNameLabel.constraints)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: friendNameLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: friendNameLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: friendNameLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: friendNameLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
