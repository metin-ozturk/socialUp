//
//  WhenToDoHourDetail.swift
//  SocialUp
//
//  Created by Metin Öztürk on 8.12.2018.
//  Copyright © 2018 Metin Ozturk. All rights reserved.
//

import UIKit

protocol WhenToDoHourDetailDelegate : class {
    func dismissWhenToDoHourDetailAndShadedBackground(hourAndMinute: String)
}

class WhenToDoHourDetail : UIView {
    weak var delegateOfWhenToDoHourDetailDelegate: WhenToDoHourDetailDelegate?
        
    var initialHourMinute : String?
    var finalHourMinute : String?
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var initialTimePicker: UIDatePicker!
    @IBOutlet weak var finalTimePicker: UIDatePicker!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializeNib()
        self.backgroundColor = UIColor.white
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        initialTimePicker.date = dateFormatter.date(from: "09:00")!
        finalTimePicker.date = dateFormatter.date(from: "12:00")!
    }
    
    
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        
        let calendar = Calendar.current
        
        var date = initialTimePicker.date
        var currentDate = calendar.dateComponents(in: .autoupdatingCurrent, from: date)
        
        if let hour = currentDate.hour, let minute = currentDate.minute {
            let textFormatter = NumberFormatter()
            textFormatter.minimumIntegerDigits = 2
            initialHourMinute = "\(textFormatter.string(from: hour as NSNumber)!)\(textFormatter.string(from: minute as NSNumber)!)"
        }
        
        
        date = finalTimePicker.date
        currentDate = calendar.dateComponents(in: .autoupdatingCurrent, from: date)
        if let hour = currentDate.hour, let minute = currentDate.minute {
            let textFormatter = NumberFormatter()
            textFormatter.minimumIntegerDigits = 2
            finalHourMinute = "\(textFormatter.string(from: hour as NSNumber)!)\(textFormatter.string(from: minute as NSNumber)!)"
        }
        
        let hourAndMinute = initialHourMinute! + finalHourMinute!
        delegateOfWhenToDoHourDetailDelegate?.dismissWhenToDoHourDetailAndShadedBackground(hourAndMinute: hourAndMinute)
    }
    
    
}
