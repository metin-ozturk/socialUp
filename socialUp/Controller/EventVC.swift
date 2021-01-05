//
//  EventVC.swift
//  socialUp
//
//  Created by Metin Öztürk on 17.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit
import Firebase
import MapKit

protocol EventVCDelegate : class {
    func updateEventInformation(withEvent: Event, withIndexPath : IndexPath, didFavoritesChange: Bool)
    func onDeleteEvent(indexPath: IndexPath)
}

class EventVC: UIViewController, MapViewDelegate {
    weak var delegate : EventVCDelegate?

    @IBOutlet weak var friendsListContainerView: UIView!
    @IBOutlet weak var friendsList: FriendsList!
    @IBOutlet weak var shadedBackground: UIVisualEffectView!
    @IBOutlet weak var finalizeDateView: FinalizeDateWithSameVote!
    
    private var mapView : MapView?
    var event : Event?
    
    var eventFounderImage : UIImage? = UIImage(named: "imagePlaceholder")
    var votedForDates = [String : Bool]() // Votes for each proposed date of the event
    var eventArrayIndexpath: IndexPath?
    var eventResponseStatus : EventResponseStatus?
    var isFavorite : Bool?
    
    private var initialDateVotes = [String]()

    @IBOutlet private weak var eventImageView: UIImageView!
    @IBOutlet private weak var eventImageViewHeightConstraint: NSLayoutConstraint!
    
    // BEING: Set Going, Not Going, Maybe and NotResponded Buttons
    
    @IBOutlet private weak var goingButton: UIButton!
    @IBOutlet private weak var maybeButton: UIButton!
    @IBOutlet private weak var notGoingButton: UIButton!
    
    // END: Set Going, Not Going, Maybe and NotResponded Buttons
    @IBOutlet private weak var eventNameLabel: UILabel!
    @IBOutlet private weak var eventFounderNameLabel: UILabel!
    @IBOutlet private weak var eventFounderImageView: UIImageView!
    @IBOutlet private weak var eventLocationLabel: UILabel!
    @IBOutlet private weak var finalizeDateButton: UIButton!
    
    @IBOutlet private weak var eventDeleteButton: UIButton!
    @IBOutlet private weak var eventLocationButton: UIButton!
    @IBOutlet private weak var eventFavoriteButton: UIButton!
    @IBOutlet private weak var inviteFriendsButton: UIButton!
    
    @IBOutlet private weak var dateOptionsLabel: UILabel!
    
    @IBOutlet private weak var voteForDateTableView: UITableView!
    
    private var didFavoritesChange = false
    
    
    private let voteForDateTableViewReuseIdentifier = "voteForDateTableViewReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        shadedBackground.contentView.tag = ShadedBackgroundTag.allowsToDismissViewWhenTapped.rawValue
        
        if event?.hasImage == true {
            eventImageView.image = event?.image
            eventImageViewHeightConstraint.constant = self.view.frame.width * 9 / 16
        } else {
            eventImageView.isHidden = true
            eventImageViewHeightConstraint.constant = 0
        }
        
        eventNameLabel.text = event?.name
        
        finalizeDateView.delegate = self
        
        voteForDateTableView.delegate = self
        voteForDateTableView.dataSource = self
        voteForDateTableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: voteForDateTableViewReuseIdentifier)
        
        eventFounderImageView.image = eventFounderImage
        eventFounderImageView.layer.cornerRadius = 8
        eventFounderNameLabel.text = event?.founderName
        eventLocationLabel.text = event?.locationName
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)
        
        if eventResponseStatus == .notGoing {
            notGoingButton.backgroundColor = .red
        } else if eventResponseStatus == .going {
            goingButton.backgroundColor = .green
        } else if eventResponseStatus == .maybe {
            maybeButton.backgroundColor = .yellow
        }
        
        if let isEventFavorite = isFavorite, isEventFavorite {
            eventFavoriteButton.setImage(UIImage(named: "favoriteSelected"), for: .normal)
        } else {
            eventFavoriteButton.setImage(UIImage(named: "favorite"), for: UIControl.State.normal)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if event?.founderID != Auth.auth().currentUser?.uid {
            eventDeleteButton.isHidden = true
            finalizeDateButton.isHidden = true
        }
        
        initialDateVotes = event?.dateVote ?? ["Error"]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        
        if touch?.view?.tag == ShadedBackgroundTag.allowsToDismissViewWhenTapped.rawValue {
            if mapView != nil {
                mapView?.removeFromSuperview()
                mapView = nil
            }
            view.displayOrHideViewsWithAnimation(views: [shadedBackground, friendsList, friendsListContainerView, finalizeDateView], display: false)
        }
    }
    
    @IBAction private func eventDeleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Event",
                                      message: "Are you sure you want to delete the event?",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (alertAction) in
            self.view.showLoadingScreen()
            self.deleteEvent()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
        
        present(alert, animated: true)
        
    }
    
    private func deleteEvent() {
        guard let eventID = event?.ID, let founderID = event?.founderID else { return }
        let data = ["eventID" : eventID, "founderID" : founderID ]
        view.showLoadingScreen()
        Functions.functions().httpsCallable("deleteEventByID").call(data) { (result, error) in
            self.view.removeLoadingScreen()
            if let error = error {
                print("Error: ", error.localizedDescription)
                self.view.removeLoadingScreen()
                return
            }
            
            guard let indexpath = self.eventArrayIndexpath else { return }
            
            self.delegate?.onDeleteEvent(indexPath: indexpath)
            self.dismiss(animated: true, completion: nil)
            self.view.removeLoadingScreen()
        }
    }
    
    @IBAction func showEventLocationButtonTapped(_ sender: UIButton) {
        mapView = MapView()
        mapView?.delegate = self
        mapView?.layer.cornerRadius = 25
        
        let currLat = Double(event?.locationLatitude ?? "0") ?? 0
        let currLong = Double(event?.locationLongitude ?? "0") ?? 0
        
        // Just set this to some arbitrary value for to zoom to event location but not to current location
        mapView?.currentCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        mapView?.addAnnotationForEventDetail(title: event?.locationName ?? "ERROR",
            subtitle: event?.locationDescription ?? "ERROR",
            coordinate: CLLocationCoordinate2D(latitude: currLat , longitude: currLong ))
        
        view.addSubview(mapView!)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.view!, attribute: .centerX, relatedBy: .equal, toItem: mapView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.view!, attribute: .centerY, relatedBy: .equal, toItem: mapView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mapView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300),
            NSLayoutConstraint(item: mapView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        ])
        
        mapView?.isHidden = true
        
        view.displayOrHideViewsWithAnimation(views: [shadedBackground, mapView], display: true)
    }
    
    @IBAction func finalizeDateButtonTapped(_ sender: UIButton) {
        if event?.finalizedDate?.isEmpty == false {
            present(UIAlertController.showInformationAlert(message: "You already selected a final date."), animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController(title: "Finalize Date",
                                      message: "Are you sure you want to finalize the event date? \n(Most voted option will be selected)",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
            self.finalizeEventDateCheckForDatesWithSameVote()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        present(alert, animated: true)
    }
    
    private func finalizeEventDateCheckForDatesWithSameVote() {
        view.showLoadingScreen()
        guard let eventDates = event?.date, let eventVotes = event?.dateVote else { return }
        let eventDate = zip(eventDates, eventVotes)
        
        var mostVoteCount = 0
        var mostVotedDay = [String]()
        
        eventDate.forEach { (datesAndVotes) in
            let (date, vote) = datesAndVotes
            guard let voteAsInt = Int(vote) else { return }
            
            if voteAsInt > mostVoteCount {
                mostVoteCount = voteAsInt
                mostVotedDay = [date]
            } else if voteAsInt == mostVoteCount {
                mostVotedDay.append(date)
            }
        }
        
        if mostVotedDay.count > 1 {
            view.removeLoadingScreen()
            finalizeDateView.datesToPickFrom = mostVotedDay
            view.displayOrHideViewsWithAnimation(views: [shadedBackground, finalizeDateView], display: true)
        } else if let votedDay = mostVotedDay.first {
            finalizeDate(finalizedDate: votedDay)
        }
    }
    
    private func finalizeDate(finalizedDate: String) {

        guard let finalizedEvent = event, let indexPath = eventArrayIndexpath else { return }
        delegate?.updateEventInformation(withEvent: finalizedEvent, withIndexPath: indexPath, didFavoritesChange: didFavoritesChange)
        Firestore.firestore().collection("events").document(finalizedEvent.ID!).updateData(["EventStatus" : EventStatus.DateFinalized.rawValue, "FinalizedDate": finalizedDate]) { error in
            self.view.removeLoadingScreen()

            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.event?.finalizedDate = finalizedDate
            self.event?.status = EventStatus.DateFinalized.rawValue
            self.voteForDateTableView.reloadData()
        }
        

    }
    
    @IBAction func inviteFriendsButtonTapped(_ sender: UIButton) {
        friendsList.eventInvitedPersonsIDs = event?.eventWithWhomID
        friendsList.searchAfterEventCreated = true
        view.displayOrHideViewsWithAnimation(views: [shadedBackground, friendsList, friendsListContainerView], display: true)
    }
    
    @IBAction func sendInvitationToFriendsButtonTapped(_ sender: UIButton) {
        guard let eventID = event?.ID else { return }
        
        let justInvitedFriends = friendsList.returnFriendIDsAndNames(statusToBeReturned: .AboutToBeSelected)
        
        if justInvitedFriends.IDs.isEmpty {
            present(UIAlertController.showInformationAlert(message: "Please select a friend to invite."), animated: true, completion: nil)
            return
        }
        
        var justInvitedFriendsIDs = [String]()
        var justInvitedFriendsNames = [String]()

        view.showLoadingScreen()
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            let eventDocumentSnapshot : DocumentSnapshot
            
            do {
                try eventDocumentSnapshot = transaction.getDocument(Firestore.firestore().collection("events").document(eventID))
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let invitedPersonsIDs = eventDocumentSnapshot.data()?["WithWhomInvited"] as? [String],
                let invitedPersonsNames = eventDocumentSnapshot.data()?["WithWhomInvitedNames"] as? [String] else { return nil}
            
            zip(justInvitedFriends.IDs, justInvitedFriends.names).forEach { (id, name) in
                if !invitedPersonsIDs.contains(id) {
                    justInvitedFriendsIDs.append(id)
                    justInvitedFriendsNames.append(name)

                }
            }
            
            var userSpecificEventData : [String : Any] = ["EventResponseStatus" : 0, "EventIsFavorite" : false]
            self.event?.date?.forEach { (date) in
                userSpecificEventData[date] = false
            }
            
            justInvitedFriendsIDs.forEach { (justInvitedFriendID) in
                transaction.setData(userSpecificEventData, forDocument: Firestore.firestore().collection("users").document(justInvitedFriendID).collection("events").document(eventID))
            }
            
            justInvitedFriendsNames.append(contentsOf: invitedPersonsNames)
            justInvitedFriendsIDs.append(contentsOf: invitedPersonsIDs)
            
            transaction.updateData(["WithWhomInvited" : justInvitedFriendsIDs, "WithWhomInvitedNames" : justInvitedFriendsNames], forDocument: Firestore.firestore().collection("events").document(eventID))
            
            return nil
        }) { (object, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                self.view.removeLoadingScreen()
                self.event?.eventWithWhomID.append(contentsOf: justInvitedFriends.IDs)
                self.event?.eventWithWhomNames.append(contentsOf: justInvitedFriends.names)
                self.view.displayOrHideViewsWithAnimation(views: [self.shadedBackground, self.friendsList, self.friendsListContainerView], display: false)
            }
        }
        

    }
    
    private func clearWhomArray(_ whomArray: [String]) -> [String] {
        guard let userID = Auth.auth().currentUser?.uid else { return whomArray }
        var tempWhomArray = whomArray
        if let indexToBeRemoved = whomArray.firstIndex(of: userID) {
            tempWhomArray.remove(at: indexToBeRemoved)
        }
        return tempWhomArray
    }
    
    
    @objc private func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        if let docId = event?.ID, let eventDateVote = event?.dateVote, let indexPath = eventArrayIndexpath, let userID = Auth.auth().currentUser?.uid {
                        
            let eventDateVoteAsInt = eventDateVote.map { return Int($0)! }
            let initialDateVoteAsInt = initialDateVotes.map { return Int($0)! }
            
            let dateVoteChangedBy = zip(eventDateVoteAsInt, initialDateVoteAsInt).map { return $0 - $1 }
            
            Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                let eventDocumentSnapshot : DocumentSnapshot
                
                do {
                    try eventDocumentSnapshot = transaction.getDocument(Firestore.firestore().collection("events").document(docId))
                } catch let fetchError as NSError  {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                guard let readEventDateData = eventDocumentSnapshot.data()?["When"] as? [String],
                    var withWhomWillCome = eventDocumentSnapshot.data()?["WithWhomWillCome"] as? [String],
                    var withWhomMayCome = eventDocumentSnapshot.data()?["WithWhomMayCome"] as? [String],
                    var withWhomWontCome = eventDocumentSnapshot.data()?["WithWhomWontCome"] as? [String]
                else { return nil }
                
                switch self.eventResponseStatus {
                case .going where !withWhomWillCome.contains(userID):
                    withWhomWillCome.append(userID)
                    withWhomMayCome = self.clearWhomArray(withWhomMayCome)
                    withWhomWontCome = self.clearWhomArray(withWhomWontCome)
                case .maybe where !withWhomMayCome.contains(userID):
                    withWhomMayCome.append(userID)
                    withWhomWillCome = self.clearWhomArray(withWhomWillCome)
                    withWhomWontCome = self.clearWhomArray(withWhomWontCome)
                case .notGoing where !withWhomWontCome.contains(userID):
                    withWhomWontCome.append(userID)
                    withWhomWillCome = self.clearWhomArray(withWhomWillCome)
                    withWhomMayCome = self.clearWhomArray(withWhomMayCome)
                case .notResponded:
                    withWhomWillCome = self.clearWhomArray(withWhomWillCome)
                    withWhomMayCome = self.clearWhomArray(withWhomMayCome)
                    withWhomWontCome = self.clearWhomArray(withWhomWontCome)
                default:
                    print("An Error Occurred While Setting Event Response Status")
                }
                
                let readEventDate : [String] = readEventDateData.map({ (eventDateString) in
                    let startIndex = eventDateString.index(eventDateString.startIndex, offsetBy: 0)
                    let endIndex = eventDateString
                        .index(eventDateString.startIndex, offsetBy: 16)
                    let range = startIndex..<endIndex
                    
                    return String(eventDateString[range])
                })
                
                var readEventDateVote : [String] = readEventDateData.map({ (eventDateString) in
                    let startIndex = eventDateString.index(eventDateString.startIndex, offsetBy: 16)
                    return String(eventDateString[startIndex...])
                })
                
                readEventDateVote = zip(readEventDateVote, dateVoteChangedBy).map{ return String(Int($0)! + $1) }
                
                transaction.updateData(["When" : zip(readEventDate, readEventDateVote).map { $0 + $1 }, "WithWhomWillCome" : withWhomWillCome, "WithWhomWontCome": withWhomWontCome, "WithWhomMayCome" : withWhomMayCome], forDocument: Firestore.firestore().collection("events").document(docId))
                
                var votesResponseStatusAndIsFavorite : [String : Any] = [:]
    
                
                self.votedForDates.forEach { (dictItem) in
                    let (key, value) = dictItem
                    votesResponseStatusAndIsFavorite[key] = value
                }
                votesResponseStatusAndIsFavorite["EventResponseStatus"] = self.eventResponseStatus?.rawValue
                
                votesResponseStatusAndIsFavorite["EventIsFavorite"] = self.isFavorite
                
                transaction.updateData(votesResponseStatusAndIsFavorite, forDocument: Firestore.firestore().collection("users").document(userID).collection("events").document(docId))
                
                DispatchQueue.main.async {
                    self.delegate?.updateEventInformation(withEvent: self.event!, withIndexPath: indexPath, didFavoritesChange: self.didFavoritesChange)
                    self.dismiss(animated: true, completion: nil)
                }

                return readEventDateVote
            }) { (object, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                } else {
                    self.event?.dateVote = object as? [String]
                }
            }

            
        }
    }
    
    @IBAction func goingButtonTapped(_ sender: UIButton) {
        guard let eventResponse = eventResponseStatus else { return }

        switch eventResponse {
        case .notResponded:
            goingButton.backgroundColor = .green
            eventResponseStatus = .going
        case .notGoing:
            notGoingButton.backgroundColor = .lightGray
            goingButton.backgroundColor = .green
            eventResponseStatus = .going
        case .maybe:
            maybeButton.backgroundColor = .lightGray
            goingButton.backgroundColor = .green
            eventResponseStatus = .going
        case .going:
            goingButton.backgroundColor = .lightGray
            eventResponseStatus = .notResponded
        }
    }

    @IBAction func notGoingButtonTapped(_ sender: UIButton) {
        guard let eventResponse = eventResponseStatus else { return }
        
        switch eventResponse {
        case .notResponded:
            notGoingButton.backgroundColor = .red
            eventResponseStatus = .notGoing
        case .notGoing:
            notGoingButton.backgroundColor = .lightGray
            eventResponseStatus = .notResponded
        case .maybe:
            maybeButton.backgroundColor = .lightGray
            notGoingButton.backgroundColor = .red
            eventResponseStatus = .notGoing
        case .going:
            goingButton.backgroundColor = .lightGray
            notGoingButton.backgroundColor = .red
            eventResponseStatus = .notGoing
        }
    }
    
    @IBAction func maybeButtonTapped(_ sender: UIButton) {
        guard let eventResponse = eventResponseStatus else { return }
        
        switch eventResponse {
        case .notResponded:
            maybeButton.backgroundColor = .yellow
            eventResponseStatus = .maybe
        case .notGoing:
            notGoingButton.backgroundColor = .lightGray
            maybeButton.backgroundColor = .yellow
            eventResponseStatus = .maybe
        case .maybe:
            maybeButton.backgroundColor = .lightGray
            eventResponseStatus = .notResponded
        case .going:
            goingButton.backgroundColor = .lightGray
            maybeButton.backgroundColor = .yellow
            eventResponseStatus = .maybe
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        if let isEventFavorite = isFavorite, isEventFavorite {
            eventFavoriteButton.setImage(UIImage(named: "favorite"), for: UIControl.State.normal)
            isFavorite = false
        } else {
            eventFavoriteButton.setImage(UIImage(named: "favoriteSelected"), for: UIControl.State.normal)
            isFavorite = true
        }
        didFavoritesChange = !didFavoritesChange
    }
    
}

extension EventVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if event?.status == EventStatus.DateFinalized.rawValue {
            return 1
        }
        return event?.date?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: voteForDateTableViewReuseIdentifier, for: indexPath) as! EventCell
        
        if let finalizedDate = event?.finalizedDate, event?.status ==  EventStatus.DateFinalized.rawValue  {
            cell.dateVoteLabel.text = ""
            cell.dateLabel.text = Event.convertEventDateToReadableFormat(eventDate: finalizedDate)
            cell.selectionStyle = .none
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.none)
            cell.contentView.backgroundColor = .green
            return cell
        }
        
        if let date = event?.date?[indexPath.row], let vote = event?.dateVote?[indexPath.row] {
            let dateAsReadableString = Event.convertEventDateToReadableFormat(eventDate: date)
            cell.dateLabel.text = dateAsReadableString
            cell.dateVoteLabel.text = vote
            cell.selectionStyle = .none // makes the default gray highlight when a row is selected appears disabled


            if votedForDates[date] == true && cell.isSelected == false {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                cell.contentView.backgroundColor = .green
            } else if votedForDates[date] == false && cell.isSelected == true {
                tableView.deselectRow(at: indexPath, animated: false)
                cell.contentView.backgroundColor = .clear
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EventCell
        
        guard event?.status == EventStatus.Default.rawValue else { return }
        
        cell.contentView.backgroundColor = .green

        if let vote = event?.dateVote?[indexPath.row], let eventDate = event?.date?[indexPath.row]  {
            var voteAsInt = Int(vote)!
            voteAsInt += 1
            event?.dateVote?[indexPath.row] = String(voteAsInt)
            cell.dateVoteLabel.text = String(voteAsInt)
            votedForDates[eventDate] = true

        }

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EventCell
        
        guard event?.status == EventStatus.Default.rawValue else { return }
        cell.contentView.backgroundColor = .white
        
        if let vote = event?.dateVote?[indexPath.row], let eventDate = event?.date?[indexPath.row] {
            var voteAsInt = Int(vote)!
            voteAsInt -= 1
            event?.dateVote?[indexPath.row] = String(voteAsInt)
            cell.dateVoteLabel.text = String(voteAsInt)
            votedForDates[eventDate] = false
        }
    }
}

extension EventVC : FinalizeDateWithSameVoteDelegate {
    func onDateConfirmed(confirmedDate: String) {
        finalizeDate(finalizedDate: confirmedDate)
        view.displayOrHideViewsWithAnimation(views: [shadedBackground, finalizeDateView], display: false)
    }
    
}

