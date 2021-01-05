//
//  WhatVC.swift
//  socialUp
//
//  Created by Metin Öztürk on 18.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

// FIX: view.endEditing(true) - find a better way to dismiss keyboard

import UIKit

class WhatVC: UIViewController {

    var event = Event()
    
    private let historyItemHeight : CGFloat = 25
    
    private var historyTableViewRowCount = 0
    private var pastEventsArray : [Event?]?
    
    private var isHistoryButtonClickedFirstTime = true
    private var isHistoryEventDownloadComplete = false
    
    private let eventImagePicker = UIImagePickerController()

    @IBOutlet private weak var pageTitleLabel: UILabel!
    @IBOutlet private weak var eventNameTextField: UITextField!
    @IBOutlet private weak var eventDescriptionTextField: UITextField!
    
    @IBOutlet private weak var eventImageView: UIImageView!
    @IBOutlet private weak var eventImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var eventPrivatePublicSwitch: UISwitch!
    @IBOutlet private weak var eventPublicLabel: UILabel!
    @IBOutlet private weak var eventPrivateLabel: UILabel!
        
    @IBOutlet private weak var eventHistoryButton: UIButton!
    
    @IBOutlet private weak var historyTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var eventHistoryTableView: UITableView!
    
    
    private let eventHistoryTableViewReuseIdentifier = "eventHistoryTableViewReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
                        
        eventHistoryTableView.delegate = self
        eventHistoryTableView.dataSource = self
        
        eventImagePicker.delegate = self
        eventImagePicker.allowsEditing = true
        eventImagePicker.sourceType = .photoLibrary
        
        eventNameTextField.text = event.name
        eventNameTextField.delegate = self
        
        eventDescriptionTextField.text = event.description
        eventDescriptionTextField.delegate = self
        
        eventPrivatePublicSwitch.isOn = event.isPrivate ?? false
        eventImageView.image = event.image
        
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        singleTapGesture.numberOfTapsRequired = 1
        eventImageView.addGestureRecognizer(singleTapGesture)
        
    }
    
    
    
    @objc private func singleTapped(_ sender: UITapGestureRecognizer) {
        present(eventImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func eventHistoryButtonTapped(_ sender: UIButton) {
        if isHistoryButtonClickedFirstTime {
            pastEventsArray = Array()
            Event.downloadDocIdsFromDB { (docIds) in
                let docIdsArray = docIds.count > 5 ? Array(docIds[..<5]) : docIds
                docIdsArray.forEach({ (docId) in
                    Event.downloadEventInfo(docId: docId, { (downloadedEvent) in
                        self.pastEventsArray?.append(downloadedEvent)
                        self.historyTableViewRowCount = self.pastEventsArray?.count ?? 0
                        self.eventHistoryTableView.reloadData()
                        
                        if self.historyTableViewRowCount == docIdsArray.count {
                            self.isHistoryEventDownloadComplete = true
                            self.showPastEventWithAnimation()
                        }
                    })
                })
            }
        }
        
        if isHistoryEventDownloadComplete == false && !isHistoryButtonClickedFirstTime {
            present(UIAlertController.showInformationAlert(message: "Please wait for downloading of past event to complete.", completion: nil), animated: true, completion: nil)
        } else if !isHistoryButtonClickedFirstTime {
            showPastEventWithAnimation()
        }
        
        isHistoryButtonClickedFirstTime = false
    }
    
    
    private func showPastEventWithAnimation() {
        UIView.animate(withDuration: 1) {
            self.historyTableViewHeightConstraint.constant = self.historyTableViewHeightConstraint.constant == self.historyItemHeight * CGFloat(self.historyTableViewRowCount) ? 0 : self.historyItemHeight * CGFloat(self.historyTableViewRowCount)
            self.view.layoutIfNeeded()
        }
    }
    

}


extension WhatVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            eventImageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
        
    }
}

extension WhatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyTableViewRowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: eventHistoryTableViewReuseIdentifier, for: indexPath)
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.textLabel?.text = pastEventsArray?[indexPath.row]?.name ?? "Loading..."
        cell.textLabel?.textColor = .darkText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedEvent = pastEventsArray?[indexPath.row] {
            eventNameTextField.text = selectedEvent.name
            eventDescriptionTextField.text = selectedEvent.description
            eventImageView.image = selectedEvent.image
            eventPrivatePublicSwitch.isOn = selectedEvent.isPrivate ?? false
            
            // Load past event and nullify date
            event = selectedEvent
            event.locationSelectionStatus = .aboutToBeConfirmed
            event.date = nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return historyItemHeight
    }
    
}

extension WhatVC : CreateEventProtocol {
    func updateEventInfo() {
        event.name = eventNameTextField.text
        event.description = eventDescriptionTextField.text
        event.isPrivate = eventPrivatePublicSwitch.isOn
        event.image = eventImageView.image
        event.hasImage = eventImageView.image == nil ? false : true
    }
}

extension WhatVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
