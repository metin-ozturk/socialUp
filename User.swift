//
//  User.swift
//  SocialUp
//
//  Created by Metin Öztürk on 24.12.2018.
//  Copyright © 2018 Metin Ozturk. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct User {
    var ID : String?
    var name : String?
    var email : String?
    var gender : String?
    var birthday : String?
    var friends : [String]?
    var hasActiveNotification : Bool?
    
    func returnUserInfo() -> [String : Any] {
        return ["ID": ID!, "Name": name!, "Email": email!, "Gender" : gender!, "Birthday" : birthday!, "FriendList" : friends!, "HasActiveNotification" : hasActiveNotification!]
    }
    
    static func downloadUserNotificationInfo(receiverID: String, completion: @escaping ([UserNotification]) -> Void) {
        Firestore.firestore().collection("users").document(receiverID).collection("friendshipRequests").getDocuments { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let friendshipRequestsDocs = snap?.documents else { return }
            
            let downloadGroup = DispatchGroup()
            var userNotifications = [UserNotification]()
            
            friendshipRequestsDocs.forEach { (snap) in
                var userNotification = UserNotification()
                userNotification.receiverID = receiverID
                userNotification.senderID = snap.documentID
                userNotification.notificationType = .FriendshipRequest
                userNotification.friendshipRequestStatus = FriendshipRequestStatus(rawValue: snap.data()["FriendshipRequestStatus"] as! Int)
                downloadGroup.enter()
                Storage.storage().reference().child("Images/Users/\(userNotification.senderID!)/profilePhoto.jpeg").getData(maxSize: 2048 * 2048) { (data, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        downloadGroup.leave()
                        return
                    }
                    
                    userNotification.senderImage = UIImage(data: data!)
                    userNotifications.append(userNotification)
                    downloadGroup.leave()
                }
                
                downloadGroup.enter()
                Firestore.firestore().collection("users").document(userNotification.senderID!).getDocument { (snap, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    userNotification.senderName = snap?.data()?["Name"] as? String
                    downloadGroup.leave()
                }
            }
            
            
            downloadGroup.notify(queue: .main) {
                completion(userNotifications)
            }
            
        }
    }
    
    static func downloadUserInfoForProfileViewing(userID: String, signedInUserID: String,
                                                  completion: @escaping (User, UIImage,User,Int) -> Void) {
        var downloadedUser : User?
        var downloadedUserImage: UIImage?
        var signedInUser : User?
        var friendshipRequestStatusRetrieved: Int?
        
        let downloadGroup = DispatchGroup()
        
        downloadGroup.enter()
        Firestore.firestore().collection("users").document(userID).getDocument { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let userInfoData = snap?.data() {
                downloadedUser = User(ID: userInfoData["ID"] as? String,
                                      name: userInfoData["Name"] as? String,
                                      email: userInfoData["Email"] as? String,
                                      gender: userInfoData["Gender"] as? String,
                                      birthday: userInfoData["Birthday"] as? String,
                                      friends: userInfoData["FriendList"] as? [String],
                                      hasActiveNotification: userInfoData["HasActiveNotification"] as? Bool)
            }
            downloadGroup.leave()

        }
        
        downloadGroup.enter()
        Storage.storage().reference().child("Images/Users/\(userID)/profilePhoto.jpeg").getData(maxSize: 2048 * 2048) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            downloadedUserImage = UIImage(data: data!)
            downloadGroup.leave()
        }
        
        downloadGroup.enter()

        Firestore.firestore().collection("users").document(signedInUserID).getDocument { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let signedInUserInfoData = snap?.data() {
                signedInUser = User(ID: signedInUserInfoData["ID"] as? String,
                name: signedInUserInfoData["Name"] as? String,
                email: signedInUserInfoData["Email"] as? String,
                gender: signedInUserInfoData["Gender"] as? String,
                birthday: signedInUserInfoData["Birthday"] as? String,
                friends: signedInUserInfoData["FriendList"] as? [String],
                hasActiveNotification: signedInUserInfoData["HasActiveNotification"] as? Bool)
            }
            downloadGroup.leave()
        }
    
        
        downloadGroup.enter()
        Firestore.firestore().collection("users").document(signedInUserID).collection("friendshipRequests").document(userID).getDocument { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            friendshipRequestStatusRetrieved = snap?.data()?["FriendshipRequestStatus"] as? Int
            downloadGroup.leave()
        }
        
        downloadGroup.notify(queue: .main) {
            completion(downloadedUser ?? User(), downloadedUserImage ?? UIImage(named: "imagePlaceholder")!, signedInUser ?? User(), friendshipRequestStatusRetrieved ?? 0)
        }
    }
    
    static func updateUserProfile(authResult: AuthDataResult?, completeInformationView: SignUpCompleteInformation,
                                  completion: @escaping () -> Void) {
        
        guard let user = authResult?.user else { return }
        let userReference = Firestore.firestore().collection("users").document(user.uid)
        
        // Update profilePhoto
        let imageToBeUploaded = completeInformationView.profilePhotoImageView.image
        let userProfilePhotoRef = Storage.storage().reference().child("Images/Users/\(user.uid)/profilePhoto.jpeg")
        let imageData = UIImage.jpegData(imageToBeUploaded!)
        
        // END: Upload profilePhoto
    
        var newUser = User()
        newUser.ID = user.uid
        newUser.name = completeInformationView.nameTextField.text
        newUser.email = completeInformationView.emailTextField.text
        newUser.gender = completeInformationView.genderArray[completeInformationView.genderPicker.selectedRow(inComponent: 0)]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        let birthdayAsString = dateFormatter.string(from: completeInformationView.birthdayPicker.date)
        newUser.birthday = birthdayAsString
        
        newUser.friends = [String]()
        newUser.hasActiveNotification = false
        
        let uploadUserInfo = DispatchGroup()
        
        uploadUserInfo.enter()
        userProfilePhotoRef.putData(imageData(1)!, metadata: nil) { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            uploadUserInfo.leave()
        }
        
        uploadUserInfo.enter()
        userReference.setData(newUser.returnUserInfo() as [String : Any]) { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            uploadUserInfo.leave()
        }
        
        uploadUserInfo.enter()
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = newUser.name
        changeRequest?.commitChanges(completion: { (error) in
            if let error = error {
                print(error.localizedDescription)
                uploadUserInfo.leave()
                return
            }
            uploadUserInfo.leave()
        })
        
        uploadUserInfo.notify(queue: .main) {
            completion()
        }
    }
    
    static func downloadFriendIDs(userID: String, returnFriendIDs: @escaping ([String]) -> Void) {
        Firestore.firestore().collection("users").document(userID).getDocument { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let friendList = snap?.data()?["FriendList"] as? [String] {
                returnFriendIDs(friendList)
            }
        }
    }
    
    static func downloadUserInfoAndImages(userID: String, returnUserNameAndImage: @escaping (User?, UIImage?) -> Void) {
        
        var user : User = User()
        var userImage : UIImage?
        
        let userReference = Firestore.firestore().collection("users").document(userID)
        let userImageReference = Storage.storage().reference().child("Images/Users/\(userID)/profilePhoto.jpeg")
        
        let downloadGroup = DispatchGroup()
        
        downloadGroup.enter()
        userReference.getDocument { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            let userData = snap?.data()
            user.birthday = userData?["Birthday"] as? String
            user.name = userData?["Name"] as? String
            user.email = userData?["Email"] as? String
            user.gender = userData?["Gender"] as? String
            user.friends = userData?["FriendList"] as? [String]
            user.hasActiveNotification = userData?["HasActiveNotification"] as? Bool
            user.ID = userData?["ID"] as? String
            
            downloadGroup.leave()
        }
        
        downloadGroup.enter()
        userImageReference.getData(maxSize: Int64(2048 * 2048)) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            userImage = UIImage(data: data!)
            downloadGroup.leave()
        }
        
        downloadGroup.notify(queue: .main) {
            returnUserNameAndImage(user, userImage)
        }
        
    }
    
}
