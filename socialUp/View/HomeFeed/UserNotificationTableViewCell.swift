//
//  UserNotificationTableViewCell.swift
//  socialUp
//
//  Created by Metin Öztürk on 25.12.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit
import Firebase

protocol UserNotificationTableViewCellDelegate : class {
    func onComplete(userNotification: UserNotification)
}

class UserNotificationTableViewCell: UITableViewCell {
    weak var delegate : UserNotificationTableViewCellDelegate?
    
    @IBOutlet weak var userNotificationBodyLabel: UILabel!
    @IBOutlet weak var userNotificationSenderImageView: UIImageView!
    var userNotification : UserNotification?
    @IBOutlet weak var userNotificationConfirmButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func userNotificationCancelButtonTapped(_ sender: UIButton) {
        callFriendshipCloudFunctionByName(cloudFunctionName: "removeFriendshipRequest")
    }
    @IBAction func userNotificationConfirmButtonTapped(_ sender: UIButton) {
        callFriendshipCloudFunctionByName(cloudFunctionName: "addFriend")
    }
    
    private func callFriendshipCloudFunctionByName(cloudFunctionName: String?) {
        guard let cloudFunctionName = cloudFunctionName else { return }
        guard let userID = userNotification?.receiverID, let senderID = userNotification?.senderID else { return }
        
        let data = ["userID" : userID, "senderID" : senderID]
        showLoadingScreen()
        Functions.functions().httpsCallable(cloudFunctionName).call(data) { (result, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }

            self.delegate?.onComplete(userNotification: self.userNotification!)

            self.removeLoadingScreen()
        }
    }
    
}
