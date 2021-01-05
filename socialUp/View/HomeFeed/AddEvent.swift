//
//  AddEvent.swift
//  socialUp
//
//  Created by Metin Öztürk on 17.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit


class AddEvent : UIView {
    lazy var addEventButton : UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "plus"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(addEventButtonTapped), for: UIControl.Event.touchUpInside)
        button.backgroundColor = .clear
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(addEventButton)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: addEventButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: addEventButton, attribute: .trailing, relatedBy: .equal, toItem: self , attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: addEventButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: addEventButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
    
    @objc func addEventButtonTapped(_ sender: UIButton) {
        print("Button TAPPED")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
