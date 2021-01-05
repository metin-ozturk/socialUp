//
//  UserProfile.swift
//  socialUp
//
//  Created by Metin Öztürk on 20.12.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileDelegate : class {
    func onFriendshipStatusChangeRequestSent()
}

class UserProfile : UIView {
    weak var delegate : UserProfileDelegate?
    
    @IBOutlet private weak var userProfileImage: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var friendshipStatusLabel: UILabel!
    @IBOutlet private weak var addFriendButton: UIButton!
    @IBOutlet private weak var genderImageView: UIImageView!
    
    private var friendshipRequestStatus : FriendshipRequestStatus?
    private var user : User?
    private var userImage : UIImage?
    private var signedInUser : User?
    
    private var friendshipRequestMessage : String?
    private var cloudFunctionName : String?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeNib()
    }
    
    func updateUserInfo(user: User, image: UIImage, signedInUser: User, friendshipRequestStatus : FriendshipRequestStatus) {
        
        self.friendshipRequestStatus = friendshipRequestStatus
        self.user = user
        self.userImage = image
        self.signedInUser = signedInUser
        
        userProfileImage.image = image
        userNameLabel.text = user.name
        genderImageView.image = user.gender == "Male" ? UIImage(named: "male")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "female")?.withRenderingMode(.alwaysTemplate)
        genderImageView.tintColor = user.gender == "Male" ? .blue : .systemPink
        
        
        if signedInUser.friends?.contains(user.ID ?? "") == true {
            self.friendshipRequestStatus = .AlreadyFriends
        }
        
        guard self.friendshipRequestStatus != nil, let friendName = user.name else { return }
        
        let tintedImage = UIImage(named: "inviteFriends")?.withRenderingMode(.alwaysTemplate)
        addFriendButton.setImage(tintedImage, for: .normal)

        
        switch self.friendshipRequestStatus {
        case _ where user.ID == signedInUser.ID:
            friendshipStatusLabel.text = ""
            addFriendButton.isHidden = true
        case .AlreadyFriends:
            setAddFriendImageViewAndLabel(tintColor: .green, labelText: "Already Friends", friendshipRequestMessage: "Do you want to remove \(friendName) from your friends?", cloudFunctionName: "removeFriend")
        case .ReceivedFriendshipRequest:
            setAddFriendImageViewAndLabel(tintColor: .blue, labelText: "Received Friendship Request", friendshipRequestMessage: "Will you accept \(friendName)'s friendship request?", cloudFunctionName: "addFriend")
        case .SentFriendshipRequest:
            setAddFriendImageViewAndLabel(tintColor: .cyan, labelText: "Sent Friendship Request", friendshipRequestMessage: "Do you want to withdraw your friendship request to \(friendName)?", cloudFunctionName: "removeFriendshipRequest")
        case .NoFriendshipRequest:
            setAddFriendImageViewAndLabel(tintColor: .black, labelText: "Add As Friend", friendshipRequestMessage: "Do you want to add \(friendName) as your friend?", cloudFunctionName: "sendFriendshipRequestByToken")
        default:
            friendshipStatusLabel.text = "An Error Occured."
            addFriendButton.isHidden = true
        }
    }
    
    private func setAddFriendImageViewAndLabel(tintColor: UIColor, labelText: String, friendshipRequestMessage : String, cloudFunctionName: String) {
        addFriendButton.isHidden = false
        addFriendButton.tintColor = tintColor
        friendshipStatusLabel.text = labelText
        self.friendshipRequestMessage = friendshipRequestMessage
        self.cloudFunctionName = cloudFunctionName
    }
    
    @IBAction private func addFriendButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Friendship Request", message: friendshipRequestMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.callFriendshipCloudFunctionByName(cloudFunctionName: self.cloudFunctionName)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            if self.friendshipRequestStatus == .ReceivedFriendshipRequest {
                self.callFriendshipCloudFunctionByName(cloudFunctionName: "removeFriendshipRequest")
            }
        }))
        
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        
        keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func callFriendshipCloudFunctionByName(cloudFunctionName: String?) {
        guard let cloudFunctionName = cloudFunctionName else { return }
        guard let userID = user?.ID, let senderID = signedInUser?.ID,
            let senderName = signedInUser?.name else { return }
        
        let data = ["userID" : userID, "senderID" : senderID, "senderName" : senderName]
        showLoadingScreen()
        Functions.functions().httpsCallable(cloudFunctionName).call(data) { (result, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            self.delegate?.onFriendshipStatusChangeRequestSent()
            self.removeLoadingScreen()
        }
    }

}
