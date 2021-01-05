//
//  SlidingMenu.swift
//  socialUp
//
//  Created by Metin Öztürk on 26.06.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit
import Firebase

class SlidingMenu : UIView {
    
    private let buttonHeight : CGFloat = 48
    
    private let itemNames = ["Edit Profile", "Settings"]
    private let itemImageNames = ["edit", "settings"]
    
    private let menuItemsCollectionViewIdentifier = "MenuItemsCollectionViewIdentifier"
    private let eventsListTableViewIdentifier = "EventsListTableViewIdentifier"
    
    private var eventArray = [Event]() {
        didSet {
            eventsListTableView.reloadData()
        }
    }
    
    private lazy var menuItemsCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(MenuItemCollectionViewCell.self, forCellWithReuseIdentifier: menuItemsCollectionViewIdentifier)
        return cv
    }()
    
    private lazy var eventsListTableView : UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: eventsListTableViewIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0
        
        setMenuItemCollectionView()
        setEventsListTableView()

        Event.downloadDocIdsFromDB({ (eventIds) in
            eventIds.forEach({ (eventId) in
                Event.downloadEventInfo(docId: eventId, { (event) in
                    self.eventArray.append(event)
                })
            })
        })
    }


    private func setMenuItemCollectionView() {
        addSubview(menuItemsCollectionView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: menuItemsCollectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: menuItemsCollectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: menuItemsCollectionView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: menuItemsCollectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1/2, constant: 0)
            ])
    }
    
    private func setEventsListTableView() {
        addSubview(eventsListTableView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: eventsListTableView, attribute: .top, relatedBy: .equal, toItem: menuItemsCollectionView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventsListTableView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventsListTableView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eventsListTableView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

extension SlidingMenu :  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: menuItemsCollectionViewIdentifier, for: indexPath) as! MenuItemCollectionViewCell
        cell.label.text = itemNames[indexPath.row]
        cell.imageView.image = UIImage(named: itemImageNames[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: buttonHeight)
    }
}

extension SlidingMenu : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: eventsListTableViewIdentifier, for: indexPath)
        cell.textLabel?.text = eventArray[indexPath.row].name
        return cell
    }
    
}

class MenuItemCollectionViewCell : UICollectionViewCell {
    
    private let buttonHeight : CGFloat = 48
    
    lazy var label : UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.text = "Loading"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    lazy var imageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "imagePlaceholder"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIImageView.ContentMode.scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setButtonAndImageView()
    }
    
    private func setButtonAndImageView() {
        addSubview(label)
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -buttonHeight),
            NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: label, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
