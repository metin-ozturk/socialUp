//
//  EventCustomCell.swift
//  socialUp
//
//  Created by Metin Öztürk on 18.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

class EventCustomCell : UITableViewCell {
    
    var dateLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    var dateVoteLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .right
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        addSubview(dateLabel)
        addSubview(dateVoteLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: dateLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: dateLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 2/3, constant: 0),
            NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dateLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: dateVoteLabel, attribute: .leading, relatedBy: .equal, toItem: dateLabel, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dateVoteLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dateVoteLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dateVoteLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
