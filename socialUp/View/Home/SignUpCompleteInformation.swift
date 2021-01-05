//
//  SignUpCompleteInformation.swift
//  SocialUp
//
//  Created by Metin Öztürk on 19.01.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import FirebaseAuth
import UIKit

protocol SignUpCompleteInformationDelegate : class {
    func confirmButtonTapped(authResult: AuthDataResult)
    func presentImagePicker()
}

class SignUpCompleteInformation : UIView {
    
    weak var delegate : SignUpCompleteInformationDelegate?
    
    var authResult : AuthDataResult?
    let genderArray = ["Female", "Male"]

    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeNib()
        
        backgroundColor = .white
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderPicker.selectRow(0, inComponent: 0, animated: false)
        
        birthdayPicker.timeZone = .current
        birthdayPicker.datePickerMode = .date
        birthdayPicker.date = Date(timeIntervalSinceReferenceDate: TimeInterval())
        
        profilePhotoImageView.contentMode = .scaleAspectFit
        profilePhotoImageView.image = UIImage(named: "imagePlaceholder")
    }
    
    
    func clearView() {
        profilePhotoImageView.image = nil
        birthdayPicker.date = Date(timeIntervalSinceReferenceDate: TimeInterval())
        genderPicker.selectRow(0, inComponent: 0, animated: false)
        nameTextField.text = ""
        emailTextField.text = ""
        
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        if let authResult = authResult {
            delegate?.confirmButtonTapped(authResult: authResult)
        }
    }
    
    @IBAction func uploadProfilePhotoButtonTapped(_ sender: UIButton) {
        delegate?.presentImagePicker()
    }
    
    
}

extension SignUpCompleteInformation : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        pickerLabel.font = UIFont.systemFont(ofSize: 14)
        pickerLabel.textAlignment = .center
        
        pickerLabel.text = genderArray[row]
        
        return pickerLabel as UIView
    }
}
