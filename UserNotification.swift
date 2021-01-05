//
//  UserNotification.swift
//  socialUp
//
//  Created by Metin Öztürk on 25.12.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

enum NotificationType : Int {
    case FriendshipRequest = 1
}

struct UserNotification {
    var notificationType : NotificationType?
    var friendshipRequestStatus : FriendshipRequestStatus?
    var senderID : String?
    var receiverID: String?
    var senderImage: UIImage?
    var senderName: String?
}
