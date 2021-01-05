//
//  UserNotificationList.swift
//  socialUp
//
//  Created by Metin Öztürk on 25.12.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

class UserNotificationList : UIView {
    @IBOutlet weak var userNotificationLabel: UILabel!
    @IBOutlet weak var userNotificationTableView: UITableView!
    
    private var notificationArray = [UserNotification]() {
        didSet {
            userNotificationTableView.reloadData()
        }
    }
    
    private let reuseIdentifier = "UserNotificationTableViewCell"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeNib()
        
        userNotificationTableView.delegate = self
        userNotificationTableView.dataSource = self
        
        userNotificationTableView.register(UINib(nibName: "UserNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
    }
    
    func loadNotifications(notifications: [UserNotification]) {
        notificationArray = notifications
    }
}

extension UserNotificationList : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserNotificationTableViewCell
        cell.delegate = self
        let currentNotification = notificationArray[indexPath.row]
        if currentNotification.notificationType == .FriendshipRequest {
            if currentNotification.friendshipRequestStatus == .ReceivedFriendshipRequest {
                cell.userNotificationConfirmButton.isHidden = false
                cell.userNotificationBodyLabel.text = "\(currentNotification.senderName ?? "") sent you a friendship request."
            } else if currentNotification.friendshipRequestStatus == .SentFriendshipRequest {
                cell.userNotificationConfirmButton.isHidden = true
                cell.userNotificationBodyLabel.text = " You sent a friendship request to \(currentNotification.senderName ?? "")."
            }
            cell.userNotification = currentNotification
            cell.userNotificationSenderImageView.image = currentNotification.senderImage
        }
        return cell
    }
}

extension UserNotificationList : UserNotificationTableViewCellDelegate {
    func onComplete(userNotification: UserNotification) {
        notificationArray.remove(at: notificationArray.firstIndex(where: {$0.senderID == userNotification.senderID})!)
        
        userNotificationTableView.reloadData()
    }
}
