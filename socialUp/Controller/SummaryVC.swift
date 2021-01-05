//
//  SummaryVC.swift
//  socialUp
//
//  Created by Metin Öztürk on 22.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit
import Firebase
import MapKit

protocol SummaryVCDelegate : class {
    func onEventCreationFinish()
}

class SummaryVC: UIViewController, CreateEventProtocol {

    var event = Event()
    
    weak var delegate : SummaryVCDelegate?
    
    private var eventReference : DocumentReference!
    private var userEventReference : DocumentReference!
    
    private var votedForDates = [String : Bool]()
    private var isFavorite : Bool?

    private let titleHeight : CGFloat = 80
    private let upperMargin : CGFloat = 20
    private let buttonHeight : CGFloat = 40
        
    @IBOutlet private weak var pageTitleLabel: UILabel!
    @IBOutlet private weak var eventImageView: UIImageView!
    @IBOutlet private weak var summaryTextView: UITextView!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    @IBOutlet private weak var eventImageViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        eventImageViewHeightConstraint.constant = view.frame.width * 9 / 16
        
        guard let loggedInUserId = Auth.auth().currentUser?.uid else { return }

        eventReference = Firestore.firestore().collection("events").document()
        userEventReference = Firestore.firestore().collection("users").document(loggedInUserId).collection("events").document(eventReference.documentID)
        
        
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        // There is height here instead of width because current orientation's height is the next one's width
        eventImageViewHeightConstraint.constant = view.frame.height * 9 / 16
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("OSMAN ", event.eventWithWhomNames)
        initializeEventInfo()
        eventImageView.image = event.image != nil ? event.image : UIImage(named: "imagePlaceholder")
    }
    
    
    private func initializeEventInfo() {
        guard let loggedInUserId = Auth.auth().currentUser?.uid else { return }
        guard let loggedInUsername = Auth.auth().currentUser?.displayName else { return }
        
        event.timestamp = FieldValue.serverTimestamp()
        event.founderID = loggedInUserId
        event.founderName = loggedInUsername
        event.status = 0
        event.finalizedDate = ""
        event.ID = eventReference.documentID
        event.dateVote = Array(repeating: "0", count: event.date?.count ?? 0)
        isFavorite = false
        
        event.eventWithWhomID.append(loggedInUserId)
        event.eventWithWhomNames.append(loggedInUsername)
        
        if let eventDate = event.date {
            eventDate.forEach { votedForDates[$0] = false }
        }
        
        if let latitude = event.locationLatitude, let longitude = event.locationLongitude {
            getAddressFromLatLon(latitude: String(latitude), longitude: String(longitude)) { (eventAddress) in
                self.event.locationAddress = eventAddress
                self.summaryTextView.attributedText = self.setSummaryText()
            }
        }
        summaryTextView.attributedText = setSummaryText()
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        view.showLoadingScreen()
        confirmButton.backgroundColor = .green

        if event.hasImage == true {
            let storageRef = Storage.storage().reference().child("Images/Events/\(eventReference.documentID)/eventPhoto.jpeg")
            let eventImageData = UIImage.jpegData(event.image!)
            
            storageRef.putData(eventImageData(1)!, metadata: nil) { (meta, error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.view.removeLoadingScreen()
                    return
                }
                self.setEventData()
            }
        } else {
            setEventData()
        }
    }
    
    private func setEventData() {
        let batch = Firestore.firestore().batch()
        
        batch.setData((event.returnEventAsDictionary()), forDocument: eventReference)
        
        var userSpecificEventData : [String : Any] = ["EventResponseStatus" : 0, "EventIsFavorite" : isFavorite!]
        event.date?.forEach { (date) in
            userSpecificEventData[date] = false
        }
        batch.setData(userSpecificEventData, forDocument: userEventReference)

        // For invitees, there isn't any favorite event.
        userSpecificEventData["EventIsFavorite"] = false
        
        event.eventWithWhomID.forEach({ (inviteeID) in
            batch.setData(userSpecificEventData, forDocument: Firestore.firestore().collection("users").document(inviteeID).collection("events").document(eventReference.documentID))
        })
        
        batch.commit { (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.view.removeLoadingScreen()
            self.delegate?.onEventCreationFinish()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        if let isEventFavorite = isFavorite {
            isFavorite = !isEventFavorite
            !isEventFavorite ? favoriteButton.setImage(UIImage(named: "favoriteSelected"), for: UIControl.State.normal) : favoriteButton.setImage(UIImage(named: "favorite"), for: UIControl.State.normal)

        }
    }
    
    
    private func getAddressFromLatLon(latitude: String, longitude: String, _ completion: @escaping (String) -> Void) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        let lat: Double = Double("\(latitude)")!
        let lon: Double = Double("\(longitude)")!
        
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        var addressString : String = ""
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                }
                
                completion(addressString)
        })
    }
    
    
    private func setSummaryText() -> NSMutableAttributedString {

        var eventDateAsReadableString = String()
        event.date?.forEach({ (eventDate) in
            eventDateAsReadableString.append(contentsOf: Event.convertEventDateToReadableFormat(eventDate: eventDate) + "\n")
        })
        
        var eventWhoAreInvited = String()
        event.eventWithWhomNames.forEach { (friendName) in
            eventWhoAreInvited.append(contentsOf: " " + friendName + ",")
        }
        eventWhoAreInvited = String(eventWhoAreInvited.dropLast())
        eventWhoAreInvited = String(eventWhoAreInvited.dropFirst())
        
        let summaryText = "Event Name: \(event.name ?? "")\nEvent Description: \(event.description ?? "")\nEvent is Private: \(event.isPrivate ?? false)\nEvent Founder Name: \(event.founderName ?? "")\nWho is Invited: \(eventWhoAreInvited )\nLocation Name: \(event.locationName ?? "")\nLocation Description: \(event.locationDescription ?? "")\nLocation Address: \(event.locationAddress ?? "")\nWhen: \(eventDateAsReadableString )\n" as NSString
        
        
        let attributedString = NSMutableAttributedString(string: summaryText as String, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)])
        
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]
        
        attributedString.addAttributes(boldFontAttribute, range: summaryText.range(of: "Event Name:"))
        attributedString.addAttributes(boldFontAttribute, range: summaryText.range(of: "Event Description:"))
        attributedString.addAttributes(boldFontAttribute, range: summaryText.range(of: "Event is Private:"))
        attributedString.addAttributes(boldFontAttribute, range: summaryText.range(of: "Event Founder Name:"))
        attributedString.addAttributes(boldFontAttribute, range: summaryText.range(of: "Who is Invited:"))
        attributedString.addAttributes(boldFontAttribute, range: summaryText.range(of: "Location Name:"))
        attributedString.addAttributes(boldFontAttribute, range: summaryText.range(of: "Location Description:"))
        attributedString.addAttributes(boldFontAttribute, range: summaryText.range(of: "Location Address:"))
        attributedString.addAttributes(boldFontAttribute, range: summaryText.range(of: "When:"))
        
        return attributedString
    }
    
    
    

}
