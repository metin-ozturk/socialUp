//
//  WhoVC.swift
//  socialUp
//
//  Created by Metin Öztürk on 19.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit
import Firebase

class WhoVC: UIViewController {
    
    var event = Event()

    private let titleHeight : CGFloat = 80
    private let upperMargin : CGFloat = 20
    
    @IBOutlet private weak var pageTitleLabel: UILabel!
    @IBOutlet private weak var friendsList: FriendsList!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // To prevent carry-over selection from previous event history selections and to refresh selected friends list
        friendsList.eventInvitedPersonsIDs = event.eventWithWhomID
    }
    

}

extension WhoVC : CreateEventProtocol {
    func updateEventInfo() {
        //Only include friends who are selected for the event
        let invitedFriendIDsAndNames = friendsList.returnFriendIDsAndNames(statusToBeReturned: FriendInviteStatus.Selected)
        event.eventWithWhomID = invitedFriendIDsAndNames.IDs// Return IDs
        event.eventWithWhomNames = invitedFriendIDsAndNames.names // Return Names
    }
    
    
}

