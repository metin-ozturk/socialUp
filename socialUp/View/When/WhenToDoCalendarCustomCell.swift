//
//  WhenToDoCalendarCustomCell.swift
//  socialUp
//
//  Created by Metin Öztürk on 29.11.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

class WhenToDoCalendarCustomCell : UICollectionViewCell {
    let dayLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .darkGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightGray
        setupDayLabel()
    }
    
    private func setupDayLabel() {
        addSubview(dayLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: dayLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dayLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: dayLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.2, constant: 0),
            NSLayoutConstraint(item: dayLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.8, constant: 0)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
}
