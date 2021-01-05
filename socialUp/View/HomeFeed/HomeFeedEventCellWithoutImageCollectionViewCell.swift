//
//  HomeFeedEventCellWithoutImageCollectionViewCell.swift
//  socialUp
//
//  Created by Metin Öztürk on 13.12.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

class HomeFeedEventCellWithoutImage: UICollectionViewCell {
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventOrganizerNameLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventOrganizerProfilePhoto: UIImageView!
    @IBOutlet weak var eventGoToMapIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        eventOrganizerProfilePhoto.layer.cornerRadius = 20
    }
    
    func setEventInformation(eventsArray: [Event], indexPath: IndexPath) {

        eventOrganizerProfilePhoto.image = eventsArray[indexPath.row].founderImage
        eventNameLabel.text =  eventsArray[indexPath.row].name
        eventLocationLabel.text = eventsArray[indexPath.row].locationName
        eventOrganizerNameLabel.text = eventsArray[indexPath.row].founderName
        
        if eventsArray[indexPath.row].date?.count == 1 {
            eventDateLabel.text = Event.convertEventDateToReadableFormat(eventDate: eventsArray[indexPath.row].date!.first!)
        } else if eventsArray[indexPath.row].date?.count ?? 0 > 1 {
            eventDateLabel.text = "Multiple Dates are Proposed"
        } else {
            eventDateLabel.text = "Error"
        }
    }

}
