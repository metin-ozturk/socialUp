//
//  AddAnnotationDetail.swift
//  SocialUp
//
//  Created by Metin Öztürk on 10.12.2018.
//  Copyright © 2018 Metin Ozturk. All rights reserved.
//

import UIKit
import CoreLocation

protocol AddAnnotationDetailDelegate : class {
    func onConfirmAnnotationInfo(title: String, subtitle: String, coordinates: CLLocationCoordinate2D)
}

class AddAnnotationDetail : UIView {
    
    weak var delegateOfAddAnnotationDetail : AddAnnotationDetailDelegate?
    
    @IBOutlet weak var annotationTitleLabel: UILabel!
    @IBOutlet weak var annotationTitleTextField: UITextField!
    @IBOutlet weak var annotationSubtitleLabel: UILabel!
    @IBOutlet weak var annotationSubtitleTextField: UITextField!
    @IBOutlet weak var annotationLatitudeLabel: UILabel!
    @IBOutlet weak var annotationLongitudeLabel: UILabel!
    
    @IBOutlet weak var annotationLatitudeValueLabel: UILabel!
    @IBOutlet weak var annotationLongitudeValueLabel: UILabel!
    
    var coordinates : CLLocationCoordinate2D!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeNib()
        
        annotationTitleTextField.delegate = self
        annotationSubtitleTextField.delegate = self
        
        self.backgroundColor = UIColor.white
    }

    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        annotationTitleTextField.resignFirstResponder()
        annotationSubtitleTextField.resignFirstResponder()
        delegateOfAddAnnotationDetail?.onConfirmAnnotationInfo(title: annotationTitleTextField.text!, subtitle: annotationSubtitleTextField.text!, coordinates: CLLocationCoordinate2D(latitude: Double(annotationLatitudeValueLabel.text!)!, longitude: Double(annotationLongitudeValueLabel.text!)!))
    }
    
}

extension AddAnnotationDetail : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
