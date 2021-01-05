
// FIX: WHEN VIEW APPEARS - IT ONLY DOWNLOADS FIRST TIME, FIX IT?
// FIX: searchBar.endEditing(true) - Find something better to dismiss keyboard

import UIKit
import GoogleSignIn
import FirebaseAuth
import FBSDKLoginKit
import Firebase
import InstantSearch


class HomeFeedVC: UIViewController {
    
    private let index = Client(appID: "3UQQK7YRC5", apiKey: "2b6893313fb23c6d06eed7c75730d41e").index(withName: "usersAndEvents")
    
    private let searchCompleted = Notification.Name("searchCompleted")
    
    private let eventsToShow : Int = 5 // per load
    private var eventDocIDs = [String]()
    private var previouslyViewedCellIndexPaths = [Int]()
    private let eventNumberToBeDownloadedTotal = 10 // in total
    
    
    private var numberOfFavoriteEvents = 0
    private var favoriteEvent : Event?
    private var favoriteEvents : [Event]?
    private var isFavoriteButtonsExpanded : Bool = false
    private var favoriteEventWarningToShow = "Please wait favorite events to be downloaded."
    
    private var eventsArray = [Event]()
    
    private var eventPageToBePassedOver : EventVC?
    
    private var searchResults : [String]? = [String]() {
        didSet {
            searchResultsTableView.reloadData()
        }
    }
    private var idResults : [String]? = [String]()
    private var isEvent = [String : Bool]()
    
    private let searchResultsTableViewIdentifier = "searchResultsTableViewCell"
    private let heightForSearchResultTableViewRow : CGFloat = 50
    
    private var searchTimer : Timer!
    
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private let profileButtonWidth : CGFloat = 40
    @IBOutlet private weak var profileButton: UIButton!
        
    @IBOutlet private weak var searchResultsTableView: UITableView!
    @IBOutlet private weak var searchTableViewHeightRowConstraint: NSLayoutConstraint!
    private var homeFeedCellReuseIdentifier = "homeFeedCellReuseIdentifier"
    private var homeFeedCellWithoutImageReuseIdentifier = "homeFeedCellWithoutImageReuseIdentifier"
    
    @IBOutlet private weak var homeFeedCollectionView: UICollectionView!

    @IBOutlet private weak var addEventButton: UIButton!
    @IBOutlet private weak var topFavoriteEventButton: UIButton!
    @IBOutlet private weak var leadingFavoriteEventButton: UIButton!
    @IBOutlet private weak var trailingFavoriteEventButton: UIButton!
    @IBOutlet weak var userNotificationList: UserNotificationList!
    
    @IBOutlet private weak var shadedBackground: UIVisualEffectView!
    @IBOutlet private weak var userProfile: UserProfile!
    @IBOutlet private weak var hasActiveNotificationButton: UIButton!
    
    private var activeNotificationListener : ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadedBackground.contentView.tag = ShadedBackgroundTag.allowsToDismissViewWhenTapped.rawValue
        
        searchBar.delegate = self
        profileButton.layer.cornerRadius = profileButtonWidth * 0.5
        
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        
        userProfile.delegate = self
        
        topFavoriteEventButton.layer.cornerRadius = 40
        leadingFavoriteEventButton.layer.cornerRadius = 40
        trailingFavoriteEventButton.layer.cornerRadius = 40

        
        homeFeedCollectionView.register(UINib(nibName: "HomeFeedEventCellWithoutImage", bundle: nil), forCellWithReuseIdentifier: homeFeedCellWithoutImageReuseIdentifier)
        homeFeedCollectionView.register(UINib(nibName: "HomeFeedEventCell", bundle: nil), forCellWithReuseIdentifier: homeFeedCellReuseIdentifier)
        
        homeFeedCollectionView.delegate = self
        homeFeedCollectionView.dataSource = self
        
        
        view.backgroundColor = .white
        
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addEventLongPressed))
        addEventButton.addGestureRecognizer(longPressGesture)
        
        let logOutLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(logOutLongPressed))
        profileButton.addGestureRecognizer(logOutLongPressGesture)
        
        let hasActiveNotificationTapGesture = UITapGestureRecognizer(target: self, action: #selector(hasActiveNotificationTapped))
        profileButton.addGestureRecognizer(hasActiveNotificationTapGesture)
        
        hasActiveNotificationButton.layer.cornerRadius = 7.5
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchResults = nil
        idResults = nil
        isEvent = [String : Bool]()
        searchTableViewHeightRowConstraint.constant = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSearchCompleted), name: searchCompleted, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(notificationTokenChanged), name: Notification.Name("FCMToken"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "goToHomeVC", sender: self)
        } else if eventsArray.isEmpty  {
            downloadCurrentUserProfilePhoto()
            downloadEventInfoAndImages(0, 5)
            downloadFavoriteEventsAndSetButtonsWithImages()
        }
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        activeNotificationListener = Firestore.firestore().collection("users").document(userID).addSnapshotListener { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let hasActiveNotification = snap?.data()?["HasActiveNotification"] as? Bool {
                self.hasActiveNotificationButton.isHidden = !hasActiveNotification
            }
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchResults = nil
        idResults = nil
        isEvent = [String : Bool]()
        searchTableViewHeightRowConstraint.constant = 0
        eventPageToBePassedOver = nil
        favoriteEvent = nil
        
        NotificationCenter.default.removeObserver(self)
        
        //SHRINK THE LONGPRESSED ADD BUTTON
        
        UIView.animate(withDuration: 0.3) {
            self.topFavoriteEventButton.alpha = 0
            self.leadingFavoriteEventButton.alpha = 0
            self.trailingFavoriteEventButton.alpha = 0
            self.topFavoriteEventButton.isUserInteractionEnabled = false
            self.leadingFavoriteEventButton.isUserInteractionEnabled = false
            self.trailingFavoriteEventButton.isUserInteractionEnabled = false
            self.isFavoriteButtonsExpanded = false
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activeNotificationListener?.remove()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        let touch = touches.first
        if touch?.view?.tag == ShadedBackgroundTag.allowsToDismissViewWhenTapped.rawValue {
            view.displayOrHideViewsWithAnimation(views: [shadedBackground, userProfile, userNotificationList], display: false)
        }
    }
    
    @objc private func hasActiveNotificationTapped(_ sender: UITapGestureRecognizer) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        view.showLoadingScreen()
        User.downloadUserNotificationInfo(receiverID: userID) { (userNotifications) in
            self.view.removeLoadingScreen()
            self.userNotificationList.loadNotifications(notifications: userNotifications)
            self.view.displayOrHideViewsWithAnimation(views: [self.shadedBackground, self.userNotificationList], display: true)
        }
    }
    
    @IBAction func addEventButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCreateEventPageVC", sender: self)
    }
    
    @IBAction func leadingFavoriteEventButtonTapped(_ sender: UIButton) {
        favoriteEvent = favoriteEvents?[0] ?? Event()
        performSegue(withIdentifier: "goToCreateEventPageVC", sender: self)
    }
    
    @IBAction func trailingFavoriteEventButtonTapped(_ sender: UIButton) {
        favoriteEvent = favoriteEvents?[1] ?? Event()
        performSegue(withIdentifier: "goToCreateEventPageVC", sender: self)
    }
    @IBAction func topFavoriteEventButtonTapped(_ sender: Any) {
        favoriteEvent = favoriteEvents?[2] ?? Event()
        performSegue(withIdentifier: "goToCreateEventPageVC", sender: self)
    }
    
    
    @objc private func addEventLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            if numberOfFavoriteEvents == 0 {
                present(UIAlertController.showInformationAlert(message: favoriteEventWarningToShow), animated: true)
                return
            }
            if isFavoriteButtonsExpanded == false {
                UIView.animate(withDuration: 0.5, animations: {
                    switch self.numberOfFavoriteEvents {
                    case 1:
                        self.leadingFavoriteEventButton.alpha = 1
                    case 2:
                        self.leadingFavoriteEventButton.alpha = 1
                        self.trailingFavoriteEventButton.alpha = 1
                    case 3:
                        self.leadingFavoriteEventButton.alpha = 1
                        self.trailingFavoriteEventButton.alpha = 1
                        self.topFavoriteEventButton.alpha = 1
                    default:
                        return
                    }
                }) { (result) in
                    if result {
                        switch self.numberOfFavoriteEvents {
                        case 1:
                            self.leadingFavoriteEventButton.isUserInteractionEnabled = true
                        case 2:
                            self.leadingFavoriteEventButton.isUserInteractionEnabled = true
                            self.trailingFavoriteEventButton.isUserInteractionEnabled = true
                        case 3:
                            self.leadingFavoriteEventButton.isUserInteractionEnabled = true
                            self.trailingFavoriteEventButton.isUserInteractionEnabled = true
                            self.topFavoriteEventButton.isUserInteractionEnabled = true
                        default:
                            return
                        }
                    }
                }
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    switch self.numberOfFavoriteEvents {
                    case 1, 2, 3:
                        self.leadingFavoriteEventButton.alpha = 0
                        self.trailingFavoriteEventButton.alpha = 0
                        self.topFavoriteEventButton.alpha = 0
                    default:
                        return
                    }
                }) { (result) in
                    if result {
                        switch self.numberOfFavoriteEvents {
                        case 1, 2, 3:
                            self.leadingFavoriteEventButton.isUserInteractionEnabled = false
                            self.trailingFavoriteEventButton.isUserInteractionEnabled = false
                            self.topFavoriteEventButton.isUserInteractionEnabled = false
                        default:
                            return
                        }
                    }
                }
            }
            isFavoriteButtonsExpanded = !isFavoriteButtonsExpanded
        }
    }
    
    private func downloadCurrentUserProfilePhoto() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            Storage.storage().reference().child("Images/Users/\(userId)/profilePhoto.jpeg").getData(maxSize: 10 * 1024 * 1024) { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let image = UIImage(data: data!) else { return }
                
                self.profileButton.setImage(image, for: UIControl.State.normal)
                
            }
        }
    }
    
    
    
    private func downloadFavoriteEvents(_ completion: @escaping ([Event]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(userId).collection("events").whereField("EventIsFavorite", isEqualTo: true).getDocuments { (snap, err) in
            if let error = err {
                print(error.localizedDescription)
                return
            }
            guard let snap = snap else { return }
            let docIds = snap.documents.map({ (document) -> String in
                return document.documentID
            })
            
            let dispatchGroup = DispatchGroup()
            var favoriteEvents = [Event]()
                        
            docIds.forEach({ (docId) in
                dispatchGroup.enter()
                Event.downloadEventInfo(docId: docId, { (event) in
                    favoriteEvents.append(event)
                    dispatchGroup.leave()
                })
            })
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(favoriteEvents)
            })
            
        }
        
    }
    
    private func downloadEventInfoAndImages(_ startIndex: Int, _ endIndex: Int) {
        Event.downloadDocIdsFromDB { (docIDs) in
            self.eventDocIDs = docIDs
            let lastItemIndexToBeDownloaded = docIDs.count < endIndex ? docIDs.count : endIndex
            docIDs[startIndex..<lastItemIndexToBeDownloaded].forEach({ (docID) in
                Event.downloadEventInfo(docId: docID, { (event) in
                    self.eventsArray.append(event)
                    self.homeFeedCollectionView.insertItems(at: [IndexPath(row: self.eventsArray.count - 1, section: 0)])
                })
            })
            self.homeFeedCollectionView.isUserInteractionEnabled = true
            self.addEventButton.isUserInteractionEnabled = true
        }
          
    }
    
    private func downloadFavoriteEventsAndSetButtonsWithImages() {
        self.downloadFavoriteEvents({ (events) in
            self.favoriteEvents = events
            self.numberOfFavoriteEvents = events.count <= 3 ? events.count : 3
                        
            if self.numberOfFavoriteEvents > 0 {
                let leadingFavoriteImage = self.favoriteEvents?.first?.hasImage == true ? self.favoriteEvents?.first?.image : UIImage(named: "imagePlaceholder")

                self.leadingFavoriteEventButton.setImage(leadingFavoriteImage, for: UIControl.State.normal)
                
                
                if self.numberOfFavoriteEvents > 1 {
                    let trailingFavoriteImage = self.favoriteEvents?[1].hasImage == true ? self.favoriteEvents?[1].image : UIImage(named: "imagePlaceholder")
                    self.trailingFavoriteEventButton.setImage(trailingFavoriteImage, for: UIControl.State.normal)
                    
                    
                    if self.numberOfFavoriteEvents > 2 {
                        let topFavoriteImage = self.favoriteEvents?[2].hasImage == true ? self.favoriteEvents?[2].image : UIImage(named: "imagePlaceholder")
                        self.topFavoriteEventButton.setImage(topFavoriteImage, for: UIControl.State.normal)
                    }
                }
            } else if self.numberOfFavoriteEvents == 0 {
                self.favoriteEventWarningToShow = "There isn't any favorite event to show."
            }
        })
    }
    
    @objc private func logOutLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == UIGestureRecognizer.State.began,
            let userID = Auth.auth().currentUser?.uid else { return }

        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
            // Sign out
            self.view.showLoadingScreen()
            Firestore.firestore().collection("users").document(userID).updateData(["CloudMessagingToken" : ""]) { (error) in
                if let error = error as NSError? {
                    if error.code == FirestoreErrorCode.notFound.rawValue {
                        // Couldn't find user document
                        print("ERROR: User doesn't have a document.")
                    } else {
                        return
                    }
                }
                self.logOut()
                self.view.removeLoadingScreen()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    private func logOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance()?.disconnect()
            LoginManager().logOut()
            self.performSegue(withIdentifier: "goToHomeVC", sender: self)
        } catch {
            print("Error while signing out")
        }
    }
    
    
}

extension HomeFeedVC : UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @objc private func downloadSearchResults(_ timer: Timer) {
        guard let searchText = (timer.userInfo as! [String : String])["searchText"] else { return }
        
        
        index.search(Query(query: searchText)) { (content, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            var eventArray = [String]()
            var eventIdArray = [String]()
            
            var userArray = [String]()
            var userIdArray = [String]()
            
            let hits = content?["hits"] as! NSArray
            
            hits.forEach({ (hit) in
                let hitAsDict = hit as! [String: Any]
                
                if let eventName = hitAsDict["EventName"] as? String, let eventId = hitAsDict["objectID"] as? String {
                    eventArray.append(eventName)
                    eventIdArray.append(eventId)
                    
                } else if let userName = hitAsDict["UserName"] as? String, let userId = hitAsDict["objectID"] as? String {
                    userArray.append(userName)
                    userIdArray.append(userId)
                }
            })
            
            self.searchResults = userArray + eventArray
            self.idResults = userIdArray + eventIdArray
            
            userIdArray.forEach({ (userId) in
                self.isEvent[userId] = false
            })
            
            eventIdArray.forEach({ (eventId) in
                self.isEvent[eventId] = true
            })
            
            NotificationCenter.default.post(name: self.searchCompleted, object: nil)
            
        }
    }
    
    @objc private func onSearchCompleted() {
        // If the download of search results lag behind users' deleting of all letters and still show results when
        // searchText is empty, this ensures results will be empty.
        if searchBar.text == "" {
            searchResults = nil
            idResults = nil
            isEvent = [String : Bool]()
            searchResultsTableView.isHidden = true
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.lowercased()
        
        if searchTimer != nil { searchTimer.invalidate() }
        
        if searchText == "" {
            searchResults = nil
            idResults = nil
            isEvent = [String : Bool]()
            searchResultsTableView.isHidden = true
            searchBar.endEditing(true)
            return
        }
        

        searchTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(downloadSearchResults(_:)), userInfo: ["searchText" : searchText], repeats: false)
        RunLoop.current.add(searchTimer, forMode: .common)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResults = nil
        idResults = nil
        isEvent = [String : Bool]()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchResultCount = searchResults?.count, searchResultCount != Int(CGFloat(searchTableViewHeightRowConstraint.constant) / heightForSearchResultTableViewRow) {
            searchTableViewHeightRowConstraint.constant = CGFloat(searchResultCount) * heightForSearchResultTableViewRow
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }

        return searchResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchResultsTableViewIdentifier, for: indexPath)
        cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        cell.selectionStyle = .none
        
        if searchResults == nil {
            cell.textLabel?.text = "ERROR"
        } else {
            cell.textLabel?.text = searchResults?[indexPath.row]
            searchResultsTableView.isHidden = false
        }
        
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForSearchResultTableViewRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let id = idResults?[indexPath.row] else { return }
        if isEvent[id] == true {
            Event.downloadEventInfo(docId: id) { (event) in
                let eventPage = EventVC()
                eventPage.eventArrayIndexpath = indexPath
                
                eventPage.event = event
                
                self.getUserSpecificEventInformation(eventPage: eventPage)
            }
        } else if isEvent[id] == false, let userID = Auth.auth().currentUser?.uid {
            User.downloadUserInfoForProfileViewing(userID: id, signedInUserID: userID) { (downloadedUser, downloadedUserImage, signedInUser, friendshipRequestStatus) in
                self.userProfile.updateUserInfo(user: downloadedUser, image: downloadedUserImage, signedInUser: signedInUser, friendshipRequestStatus: FriendshipRequestStatus(rawValue: friendshipRequestStatus) ?? .NoFriendshipRequest)
                self.view.displayOrHideViewsWithAnimation(views: [self.shadedBackground, self.userProfile], display: true)
            }

        }
        
    }
}

extension HomeFeedVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if eventsArray[indexPath.row].hasImage == true {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFeedCellReuseIdentifier, for: indexPath) as! HomeFeedEventCell
            
            
            cell.contentView.backgroundColor = UIColor(red: 0.9, green: 0, blue: 0, alpha: 0.8)
            cell.eventImageView.backgroundColor = .white
            cell.eventImageView.image = eventsArray[indexPath.row].image
            cell.setEventInformation(eventsArray: eventsArray, indexPath: indexPath)
            cell.eventImageViewHeightConstraint.constant = self.view.frame.width * 9 / 16
            cell.eventImageViewWidthConstraint.constant = self.view.frame.width
            
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeFeedCellWithoutImageReuseIdentifier, for: indexPath) as! HomeFeedEventCellWithoutImage
            
            cell.contentView.backgroundColor = UIColor(red: 0.9, green: 0, blue: 0, alpha: 0.8)
            cell.setEventInformation(eventsArray: eventsArray, indexPath: indexPath)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if eventsArray[indexPath.row].hasImage == true {
            // if it is the initial load, we'll show four placeholders with the size of an event with an image, else height of an imageless events is 1/4 height of the event with an image.
            let heightOfPhoto = self.view.frame.width * 9 / 16
            let heightOfEventInfo = self.view.frame.width * 9 / 16 * 0.25
            let height = heightOfPhoto + heightOfEventInfo

            return CGSize(width: self.view.frame.width, height: height)
        } else {
            let height : CGFloat = self.view.frame.width * 9 / 16 * 0.25
            return CGSize(width: self.view.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.showLoadingScreen()
        let eventPage = EventVC()
        eventPage.eventArrayIndexpath = indexPath
        eventPage.event = eventsArray[indexPath.row]
        getUserSpecificEventInformation(eventPage: eventPage)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row + 1) % eventsToShow == 0 && indexPath.row + 1 < eventDocIDs.count && !previouslyViewedCellIndexPaths.contains(indexPath.row + 1) && indexPath.row + 1 < eventNumberToBeDownloadedTotal{
            
            previouslyViewedCellIndexPaths.append(indexPath.row + 1)
            let lastItemIndexToBeDownloaded = eventDocIDs.count < (indexPath.row + eventsToShow) ? eventDocIDs.count : (indexPath.row + eventsToShow)
            downloadEventInfoAndImages(indexPath.row + 1, lastItemIndexToBeDownloaded)
        }
    }
    
    private func getUserSpecificEventInformation(eventPage: EventVC) {
        guard let eventId = eventPage.event?.ID,
            let userId = Auth.auth().currentUser?.uid,
            let eventDates = eventPage.event?.date else { return }
        
        Firestore.firestore().collection("users").document(userId).collection("events").document(eventId).getDocument { (snap, error) in
            self.view.removeLoadingScreen()

            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = snap?.data() else { return }
            
            eventDates.forEach({ (eventDate) in
                eventPage.votedForDates[eventDate] = data[eventDate] as? Bool
            })
            
            guard let eventResponseStatusAsInt = data["EventResponseStatus"] as? Int else { return }
            eventPage.eventResponseStatus = EventResponseStatus(rawValue: eventResponseStatusAsInt)
            
            guard let isEventFavorite = data["EventIsFavorite"] as? Bool else { return }
            eventPage.isFavorite = isEventFavorite
            
            self.eventPageToBePassedOver = eventPage

            self.performSegue(withIdentifier: "goToEventVC", sender: self)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEventVC" {
            let destinationVC = segue.destination as! EventVC
            destinationVC.delegate = self
            destinationVC.event = eventPageToBePassedOver?.event
            destinationVC.votedForDates = eventPageToBePassedOver?.votedForDates ?? [:]
            destinationVC.isFavorite = eventPageToBePassedOver?.isFavorite
            destinationVC.eventFounderImage = eventPageToBePassedOver?.event?.founderImage
            destinationVC.eventResponseStatus = eventPageToBePassedOver?.eventResponseStatus
            destinationVC.eventArrayIndexpath = eventPageToBePassedOver?.eventArrayIndexpath
        } else if segue.identifier == "goToHomeVC" {
            eventsArray.removeAll()
            favoriteEvents?.removeAll()
            searchResults?.removeAll()
            searchResultsTableView.reloadData()
            homeFeedCollectionView.reloadData()
            profileButton.setImage(UIImage(named: "imagePlaceholder"), for: .normal)
        } else if segue.identifier == "goToCreateEventPageVC" {
            let destinationVC = segue.destination as! CreateEventPageVC
            destinationVC.createEventDelegate = self
            if let favoriteEvent = favoriteEvent {
                destinationVC.pastEvent = favoriteEvent
                destinationVC.pastEvent.date = nil
                destinationVC.pastEvent.dateVote = nil
                destinationVC.pastEvent.locationSelectionStatus = .aboutToBeConfirmed
            }
        }
    }
    
}

extension HomeFeedVC : EventVCDelegate {
    func onDeleteEvent(indexPath: IndexPath) {
        updateFavoriteEvents()
        eventsArray.remove(at: indexPath.row)
        homeFeedCollectionView.deleteItems(at: [indexPath])
    }
    
    func updateEventInformation(withEvent: Event, withIndexPath: IndexPath, didFavoritesChange: Bool) {
        eventsArray[withIndexPath.row] = withEvent
        if didFavoritesChange {
            updateFavoriteEvents()
        }
    }
    
    private func updateFavoriteEvents() {
        favoriteEvents?.removeAll()
        numberOfFavoriteEvents = 0
        favoriteEventWarningToShow = "Please wait favorite events to be downloaded."
        downloadFavoriteEventsAndSetButtonsWithImages()
    }
}

extension HomeFeedVC : UserProfileDelegate {
    func onFriendshipStatusChangeRequestSent() {
        view.displayOrHideViewsWithAnimation(views: [shadedBackground, userProfile], display: false)
    }
}

extension HomeFeedVC : CreateEventDelegate {
    func onEventCreationFinish() {
        eventsArray.removeAll()
        homeFeedCollectionView.reloadData()
    }
}
