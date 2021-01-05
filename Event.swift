//
//  Event.swift
//  socialUp
//
//  Created by Metin Öztürk on 16.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import Foundation
import Firebase

enum EventResponseStatus : Int {
    case notResponded = 0
    case notGoing = 1
    case maybe = 2
    case going = 3
}

enum EventStatus : Int {
    case Default = 0
    case DateFinalized = 1
}

struct Event {
    var timestamp : FieldValue?
    
    var ID : String?
    var name : String?
    var description : String?
    var isPrivate : Bool?
    var image : UIImage?
    
    var founderID : String?
    var founderName : String?
    var founderImage: UIImage?
    
    var status : Int?
    var date : [String]?
    var dateVote : [String]?
    var finalizedDate : String?

    var locationLatitude, locationLongitude : String?
    var locationName, locationDescription, locationAddress : String?
    var locationSelectionStatus : LocationSelectionStatus?
    
    var eventWithWhomID  = [String]()
    var eventWithWhomNames = [String]()
    var eventWithWhomWillCome = [String]()
    var eventWithWhomWontCome = [String]()
    var eventWithWhomMayCome = [String]()
    
    var hasImage : Bool?
    
    
    func returnEventAsDictionary() -> [String : Any] {
        
        return ["EventID" : ID!,
                "EventName" : name!,
                "EventDescription" : description!,
                "EventIsPrivate" : isPrivate!,
                "EventFounder" : founderID!,
                "EventFounderName" : founderName!,
                "EventStatus" : status!,
                "FinalizedDate" : finalizedDate!,
                "LocationName": locationName!,
                "LocationDescription" : locationDescription!,
                "LocationAddress" : locationAddress!,
                "LocationLatitude" : locationLatitude!,
                "LocationLongitude" : locationLongitude!,
                "WithWhomInvited" : eventWithWhomID,
                "WithWhomInvitedNames" : eventWithWhomNames,
                "WithWhomWillCome" : eventWithWhomWillCome,
                "WithWhomMayCome" : eventWithWhomMayCome,
                "WithWhomWontCome" : eventWithWhomWontCome,
                "When" : zip(date!, dateVote!).map { $0 + $1 },
                "HasImage" : hasImage!,
                "timestamp" : timestamp!]
}
    static func downloadDocIdsFromDB(_ completion: @escaping ([String]) -> Void) {
        
        guard let loggedInUserId = Auth.auth().currentUser?.uid else { return  }
        Firestore.firestore().collection("users").document(loggedInUserId).collection("events").getDocuments { (snap, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let snap = snap else { return }
            
            let documentIds = snap.documents.map { $0.documentID }
            
            completion(documentIds)
            
        }
        
    }
    
    static func downloadEventInfo(docId : String, _ completion:  @escaping (Event) -> Void) {
        
        var event = Event()
        
        
        Firestore.firestore().collection("events").document(docId).getDocument(completion: { (snap, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let snap = snap, let eventData = snap.data() else { return }
            
            event.ID = eventData["EventID"] as? String
            event.name = eventData["EventName"] as? String
            event.description = eventData["EventDescription"] as? String
            event.isPrivate = eventData["EventIsPrivate"] as? Bool
            
            event.founderID = eventData["EventFounder"] as? String
            event.founderName = eventData["EventFounderName"] as? String
            event.status = eventData["EventStatus"] as? Int
            event.finalizedDate = eventData["FinalizedDate"] as? String
            
            event.locationName = eventData["LocationName"] as? String
            event.locationDescription = eventData["LocationDescription"] as? String
            event.locationAddress = eventData["LocationAddress"] as? String
            event.locationLatitude = eventData["LocationLatitude"] as? String
            event.locationLongitude = eventData["LocationLongitude"] as? String
            
            event.eventWithWhomID = eventData["WithWhomInvited"] as! [String]
            event.eventWithWhomNames = eventData["WithWhomInvitedNames"] as! [String]
            event.eventWithWhomWillCome = eventData["WithWhomWillCome"] as! [String]
            event.eventWithWhomMayCome = eventData["WithWhomMayCome"] as! [String]
            event.eventWithWhomWontCome = eventData["WithWhomWontCome"] as! [String]
            
            event.hasImage = eventData["HasImage"] as? Bool
            event.timestamp = eventData["timestamp"] as? FieldValue
            
            // Split eventData["When"] string to eventDate and eventDateVote
            
            if let downloadedEventDateData = eventData["When"] as? [String] {
                
                event.date = downloadedEventDateData.map({ (eventDateString) in
                    let startIndex = eventDateString.index(eventDateString.startIndex, offsetBy: 0)
                    let endIndex = eventDateString
                        .index(eventDateString.startIndex, offsetBy: 16)
                    let range = startIndex..<endIndex
                    
                    return String(eventDateString[range])
                })
                
                event.dateVote = downloadedEventDateData.map({ (eventDateString) in
                    let startIndex = eventDateString.index(eventDateString.startIndex, offsetBy: 16)
                    return String(eventDateString[startIndex...])
                })
                
            }
            
            let eventGroup = DispatchGroup()
            
            eventGroup.enter()
            guard let eventFounder = event.founderID else { return }
            Storage.storage().reference().child("Images/Users/\(eventFounder)/profilePhoto.jpeg").getData(maxSize: 10 * 1024 * 1024) { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let image = UIImage(data: data!) else { return }
                event.founderImage = image
                eventGroup.leave()
            }
            
            eventGroup.enter()
            guard let eventID = event.ID else { return }
            Storage.storage().reference().child("Images/Events/\(eventID)/eventPhoto.jpeg").getData(maxSize: 10 * 1024 * 1024, completion: { (data, error) in
                if let error = error, error._code == -13010{
                    event.image = nil
                    eventGroup.leave()
                    return
                } else if let error = error {
                    print(error.localizedDescription)
                    return
                }

                guard let image = UIImage(data: data!) else { return }
                
                event.image = image
                eventGroup.leave()
            })
            
            eventGroup.notify(queue: .main, execute: {
                completion(event)
            })
        })
    }
    
    
    
    // Converts Database Date Format of Date to Readable Date Format
    
    static func convertEventDateToReadableFormat(eventDate: String) -> String {
        var startIndex = eventDate.index(eventDate.startIndex, offsetBy: 2)
        let day = String(eventDate[..<startIndex])
        
        var endIndex = eventDate.index(eventDate.startIndex, offsetBy: 4)
        var range = startIndex..<endIndex
        let month = String(eventDate[range])
        
        startIndex = eventDate.index(eventDate.startIndex, offsetBy: 4)
        endIndex = eventDate.index(eventDate.startIndex, offsetBy: 8)
        range = startIndex..<endIndex
        
        let year = String(eventDate[range])
        
        startIndex = eventDate.index(eventDate.startIndex, offsetBy: 8)
        endIndex = eventDate.index(eventDate.startIndex, offsetBy: 10)
        range = startIndex..<endIndex
        
        let initialHour = String(eventDate[range])
        
        startIndex = eventDate.index(eventDate.startIndex, offsetBy: 10)
        endIndex = eventDate.index(eventDate.startIndex, offsetBy: 12)
        range = startIndex..<endIndex
        
        let initialMinutes = String(eventDate[range])
        
        startIndex = eventDate.index(eventDate.startIndex, offsetBy: 12)
        endIndex = eventDate.index(eventDate.startIndex, offsetBy: 14)
        range = startIndex..<endIndex
        
        let finalHour = String(eventDate[range])
        
        startIndex = eventDate.index(eventDate.startIndex, offsetBy: 14)
        endIndex = eventDate.index(eventDate.startIndex, offsetBy: 16)
        range = startIndex..<endIndex
        
        let finalMinutes = String(eventDate[range])
        
        let date = day + "/" + month + "/" + year + " " + initialHour + ":" +  initialMinutes + " " + finalHour + ":" + finalMinutes
        
        return date
    }

}
