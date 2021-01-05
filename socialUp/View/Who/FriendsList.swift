//
//  FriendsListView.swift
//  socialUp
//
//  Created by Metin Öztürk on 28.11.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit
import FirebaseAuth

class FriendsList : UIView {
        
    private let rowHeight : CGFloat = 60
    
    @IBOutlet weak var searchFriendsBar: UISearchBar!
    
    @IBOutlet weak var friendsListTableView: UITableView!
    
    private let friendsListTableViewReuseIdentifier = "friendsListTableViewReuseIdentifier"
    private var friendsInfo = [FriendInfo]()
    private var initialFriendsInfo = [FriendInfo]()
    
    private var isFriendsDownloadComplete = false
    var eventInvitedPersonsIDs : [String]? {
        didSet {
            loadFriendInfoFromPastEvent()
        }
    }
    
    var searchAfterEventCreated = false
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeNib()
        searchFriendsBar.delegate = self
        
        friendsListTableView.delegate = self
        friendsListTableView.dataSource = self
        friendsListTableView.layer.borderColor = UIColor.lightGray.cgColor
        friendsListTableView.layer.borderWidth = 2
        
        friendsListTableView.register(UINib(nibName: "FriendsListCell", bundle: nil), forCellReuseIdentifier: friendsListTableViewReuseIdentifier)
        
        downloadFriends()
    }
    
    private func loadFriendInfoFromPastEvent() {
        if friendsInfo.count > 0 {
            for (friendIndex, friendInfo) in friendsInfo.enumerated() {
                if eventInvitedPersonsIDs!.contains(friendInfo.iD!) == true {
                    friendsInfo[friendIndex].friendInviteStatus = .Selected
                } else {
                    friendsInfo[friendIndex].friendInviteStatus = .NotSelected
                }
                
                friendsListTableView.reloadData()
            }
            sortFriendsInfo()
            if (friendsInfo.count == initialFriendsInfo.count) {
                initialFriendsInfo = friendsInfo
            }
        }
    }
    
    func returnFriendIDsAndNames(statusToBeReturned: FriendInviteStatus) -> (IDs: [String], names: [String]) {
        
        var invitedFriendNames = [String]()
        var invitedFriendsIDs = [String]()
        
        friendsInfo.forEach { (friendInfo) in
            guard let name = friendInfo.name, let iD = friendInfo.iD, friendInfo.friendInviteStatus == statusToBeReturned else { return }
            invitedFriendNames.append(name)
            invitedFriendsIDs.append(iD)
        }
        
        if statusToBeReturned == .Selected {
            eventInvitedPersonsIDs = invitedFriendsIDs
        }
        
        return (invitedFriendsIDs, invitedFriendNames)
    }
    
    private func downloadFriends() {
        User.downloadFriendIDs(userID: Auth.auth().currentUser!.uid) { (friendIDs) in
            if friendIDs.count == 0 {
                self.isFriendsDownloadComplete = true
                self.friendsListTableView.reloadData()
            }
            
            
            friendIDs.forEach { (friendID) in
                User.downloadUserInfoAndImages(userID: friendID) { (userInfo, userImage) in
                    
                    var friend = FriendInfo()
                    friend.name = userInfo?.name
                    friend.image = userImage
                    friend.friendInviteStatus = self.eventInvitedPersonsIDs?.contains(friendID) == true ? .Selected : .NotSelected
                    friend.iD = friendID
                    
                    self.friendsInfo.append(friend)
                    self.friendsListTableView.reloadData()

                    
                    if (self.friendsInfo.last?.iD == friendID) {
                        self.isFriendsDownloadComplete = true
                        self.sortFriendsInfo()
                        self.initialFriendsInfo = self.friendsInfo
                    }
                }
            }
        }
    }
    
}

extension FriendsList : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            friendsInfo = initialFriendsInfo
            friendsListTableView.reloadData()
            return
        }
        
        let searchedText = searchText.lowercased()
        
        friendsInfo = friendsInfo.filter { (friendInfo) -> Bool in
            friendInfo.name?.lowercased().contains(searchedText.lowercased()) == true
        }
        friendsListTableView.reloadData()
        
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let  char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")

        if (isBackSpace == -92) {
            friendsInfo = initialFriendsInfo
        }
        return true
    }
    
}


extension FriendsList : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friendsInfo.count == 0 { return 1 }
        else { return friendsInfo.count }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: friendsListTableViewReuseIdentifier, for: indexPath) as! FriendsListCell

        if friendsInfo.count == 0 {
            cell.friendProfileImageViewWidthConstraint.constant = 0
            if initialFriendsInfo.count != 0 {
                cell.friendNameLabel.text = "No friend found matching this criteria."
            } else {
                cell.friendNameLabel.text = isFriendsDownloadComplete == false ? "Loading Friends..." : "You don't have friends yet."
            }
            return cell
        }
        
        cell.friendProfileImageViewWidthConstraint.constant = 60

        let friendInfo = friendsInfo[indexPath.row]

        // Being sure whoInfoDict's .isSelected is in synchrony with tableview's .isSelected
        if friendInfo.friendInviteStatus == .Selected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            cell.contentView.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 0.8)

        } else if friendInfo.friendInviteStatus == .NotSelected {
            tableView.deselectRow(at: indexPath, animated: false)
            cell.contentView.backgroundColor = .clear
        } else {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
            cell.contentView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0, alpha: 1)
        }

        cell.friendProfileImageView.image = friendInfo.image
        cell.friendNameLabel.text = friendInfo.name
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if (searchAfterEventCreated &&
            friendsInfo[indexPath.row].friendInviteStatus != .Selected) {
            cell?.contentView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0, alpha: 1)
            friendsInfo[indexPath.row].friendInviteStatus = .AboutToBeSelected
        } else {
            cell?.contentView.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 0.8)
            friendsInfo[indexPath.row].friendInviteStatus = .Selected
        }
        
        let friendID = friendsInfo[indexPath.row].iD
        initialFriendsInfo[initialFriendsInfo.firstIndex( where: {$0.iD == friendID })!].friendInviteStatus = friendsInfo[indexPath.row].friendInviteStatus

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if ( (searchAfterEventCreated &&
            friendsInfo[indexPath.row].friendInviteStatus == .AboutToBeSelected) ||
            (!searchAfterEventCreated)) {
            
            cell?.contentView.backgroundColor = .white
            friendsInfo[indexPath.row].friendInviteStatus = .NotSelected
            
            let friendID = friendsInfo[indexPath.row].iD
            initialFriendsInfo[initialFriendsInfo.firstIndex( where: {$0.iD == friendID })!].friendInviteStatus = .NotSelected

        }
        


    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    private func sortFriendsInfo() {
        friendsInfo.sort { (firstFriend, secondFriend) -> Bool in
            if firstFriend.friendInviteStatus == .NotSelected && secondFriend.friendInviteStatus == .Selected {
                return true
            } else if firstFriend.name! < secondFriend.name! && firstFriend.friendInviteStatus == secondFriend.friendInviteStatus {
                return true
            } else { return false }
        }
    }
    
    
}
