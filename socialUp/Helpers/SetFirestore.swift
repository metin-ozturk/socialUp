//
//  SetFirestore.swift
//  SocialUp
//
//  Created by Metin Öztürk on 20.12.2018.
//  Copyright © 2018 Metin Ozturk. All rights reserved.
//

import UIKit
import Firebase

struct SetFirestore {
    var db : Firestore!
    
    init() {
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
}
