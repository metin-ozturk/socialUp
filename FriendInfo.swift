//
//  WhoInfo.swift
//  socialUp
//
//  Created by Metin Öztürk on 20.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

struct FriendInfo {
    var iD : String?
    var name : String?
    var image : UIImage?
    var friendInviteStatus : FriendInviteStatus?
}

enum FriendInviteStatus : Int {
    case NotSelected = 0
    case AboutToBeSelected = 1
    case Selected = 2
}
