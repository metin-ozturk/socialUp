//
//  FriendshipRequestStatus.swift
//  socialUp
//
//  Created by Metin Öztürk on 23.12.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import Foundation

enum FriendshipRequestStatus : Int {
    case NoFriendshipRequest = 0
    case ReceivedFriendshipRequest = 1
    case SentFriendshipRequest = 2
    case AlreadyFriends = 3
}
