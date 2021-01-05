//
//  HomeFeedCustomCell.swift
//  socialUp
//
//  Created by Metin Öztürk on 15.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

class HomeFeedCustomCellWithoutImage : UICollectionViewCell {
        
    var eventDescriptionContainer : UIView = {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .lightGray
        container.clipsToBounds = true
        return container
    }()
    
    var eventNameLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
    }()
    
    var eventOrganizerNameLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    var eventLocationLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    var eventDateLabel : UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    var eventOrganizerProfilePhoto : UIImageView = {
        let imageView = UIImageView()
        imageView.image = nil
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.8
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    var eventGoToMapIcon : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(eventDescriptionContainer)
        
        eventDescriptionContainer.addSubview(eventNameLabel)
        eventDescriptionContainer.addSubview(eventOrganizerProfilePhoto)
        eventDescriptionContainer.addSubview(eventOrganizerNameLabel)
        eventDescriptionContainer.addSubview(eventDateLabel)
        eventDescriptionContainer.addSubview(eventGoToMapIcon)
        eventDescriptionContainer.addSubview(eventLocationLabel)
        
        setEventDescriptionContainerConstraint()
        setConstraints()
        
        eventOrganizerProfilePhoto.layer.cornerRadius = self.frame.width / 20
        eventDescriptionContainer.layer.cornerRadius = 10
    }
    

    
    func setEventDescriptionContainerConstraint() {
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: eventDescriptionContainer, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventDescriptionContainer, attribute: .trailing, relatedBy: .equal, toItem: self , attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventDescriptionContainer, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventDescriptionContainer, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
    
    private func setConstraints() {
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: eventOrganizerProfilePhoto, attribute: .leading, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventOrganizerProfilePhoto, attribute: .trailing, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .trailing, multiplier: 0.1, constant: 0),
            NSLayoutConstraint(item: eventOrganizerProfilePhoto, attribute: .top, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventOrganizerProfilePhoto, attribute: .bottom, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: eventNameLabel, attribute: .leading, relatedBy: .equal, toItem: eventOrganizerProfilePhoto, attribute: .trailing, multiplier: 1, constant: 4),
            NSLayoutConstraint(item: eventNameLabel, attribute: .trailing, relatedBy: .equal, toItem: eventDescriptionContainer , attribute: .trailing, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: eventNameLabel, attribute: .top, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventNameLabel, attribute: .bottom, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .bottom, multiplier: 0.5, constant: 0)
            ])
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: eventOrganizerNameLabel, attribute: .leading, relatedBy: .equal, toItem: eventOrganizerProfilePhoto, attribute: .trailing, multiplier: 1, constant: 4),
            NSLayoutConstraint(item: eventOrganizerNameLabel, attribute: .trailing, relatedBy: .equal, toItem: eventDescriptionContainer , attribute: .trailing, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: eventOrganizerNameLabel, attribute: .top, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .bottom, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: eventOrganizerNameLabel, attribute: .bottom, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: eventDateLabel, attribute: .leading, relatedBy: .equal, toItem: eventNameLabel, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventDateLabel, attribute: .trailing, relatedBy: .equal, toItem: eventDescriptionContainer , attribute: .trailing, multiplier: 0.95, constant: 0),
            NSLayoutConstraint(item: eventDateLabel, attribute: .top, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventDateLabel, attribute: .bottom, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .bottom, multiplier: 0.5, constant: 0)
            ])
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: eventLocationLabel, attribute: .leading, relatedBy: .equal, toItem: eventOrganizerNameLabel, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventLocationLabel, attribute: .trailing, relatedBy: .equal, toItem: eventDescriptionContainer , attribute: .trailing, multiplier: 0.95, constant: 0),
            NSLayoutConstraint(item: eventLocationLabel, attribute: .top, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .bottom, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: eventLocationLabel, attribute: .bottom, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: eventGoToMapIcon, attribute: .leading, relatedBy: .equal, toItem: eventLocationLabel, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventGoToMapIcon, attribute: .trailing, relatedBy: .equal, toItem: eventDescriptionContainer , attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventGoToMapIcon, attribute: .top, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .bottom, multiplier: 0.5, constant: 0),
            NSLayoutConstraint(item: eventGoToMapIcon, attribute: .bottom, relatedBy: .equal, toItem: eventDescriptionContainer, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
