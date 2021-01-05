//
//  WhenVC.swift
//  socialUp
//
//  Created by Metin Öztürk on 21.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

class WhenVC: UIViewController {

    var event = Event()

    private let upperMargin : CGFloat = 20
    private let calendarMargin : CGFloat = 40
    
    private var dayData : [[Bool]]?
    private var dayMonthYear = [String]()
    private var hourMinuteArray = Array(repeating: Array(repeating: "", count: 31), count: 12)
    
    @IBOutlet private weak var pageTitleLabel: UILabel!
    
    @IBOutlet private weak var whenToDoCalendarView: WhenToDoCalendar!
    
    @IBOutlet private weak var whenToDoHourDetailView: WhenToDoHourDetail!
    @IBOutlet private weak var blurredBackground: UIVisualEffectView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
                
        whenToDoCalendarView.numberOfMonthsPassed = 0
        
        whenToDoCalendarView.delegateOfWhenToDoCalendar = self
        whenToDoHourDetailView.delegateOfWhenToDoHourDetailDelegate = self
        
        blurredBackground.contentView.tag = ShadedBackgroundTag.allowsToDismissViewWhenTapped.rawValue
                        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Initialize Event's Date
        event.date = nil

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        if touch?.view?.tag == ShadedBackgroundTag.allowsToDismissViewWhenTapped.rawValue {
            view.displayOrHideViewsWithAnimation(views: [whenToDoHourDetailView,blurredBackground], display: false)
        }
    }
    
    private func updateEventDate() {
        let interimComponents = whenToDoCalendarView.getInterimDateComponents(monthsPassed: 0)
        
        var didNewYearCame  = false
        var month : Int!
        dayMonthYear.removeAll()
        
        for (sectionIndex, sectionArray) in whenToDoCalendarView.isConfirmed.enumerated() {
            for (rowIndex, isConfirmed) in sectionArray.enumerated() {
                if isConfirmed {
                    let textFormatter = NumberFormatter()
                    textFormatter.minimumIntegerDigits = 2
                    
                    if interimComponents.month! + sectionIndex <= 12 {
                        month = interimComponents.month! + sectionIndex
                    } else {
                        month = interimComponents.month! + sectionIndex - 12
                        didNewYearCame = true
                    }
                    let monthString = textFormatter.string(from: month as NSNumber)!
                    
                    let year = didNewYearCame ? interimComponents.year! + 1 : interimComponents.year!
                    let yearString = textFormatter.string(from: year as NSNumber)!
                    
                    let day = rowIndex + 1
                    let dayString = textFormatter.string(from: day as NSNumber)!
                    
                    
                    let hourMinute = hourMinuteArray[sectionIndex][rowIndex]
                    dayMonthYear.append(dayString + monthString + yearString + hourMinute)
                }
            }
        }
        event.date = dayMonthYear
    }
    

}

extension WhenVC : WhenToDoCalendarDelegate {    
    func sendDayDataToHourDetailView(dayData: [[Bool]]) {
        self.dayData = dayData
    }
    
    func presentWhenToDoHourDetailPopUp() {
        view.displayOrHideViewsWithAnimation(views: [blurredBackground, whenToDoHourDetailView], display: true)
    }
    
    
}

extension WhenVC : WhenToDoHourDetailDelegate {
    
    func dismissWhenToDoHourDetailAndShadedBackground(hourAndMinute: String) {
        
        for (sectionIndex, sectionArray) in dayData!.enumerated() {
            for (rowIndex, checkIsSelected) in sectionArray.enumerated() {
                if checkIsSelected {
                    whenToDoCalendarView.isSelectedPreviously[sectionIndex][rowIndex] = false
                    whenToDoCalendarView.isConfirmed[sectionIndex][rowIndex] = true
                    hourMinuteArray[sectionIndex][rowIndex] = hourAndMinute
                    whenToDoCalendarView.whenToDoCalendar.reloadData()
                }
            }
        }
        
        view.displayOrHideViewsWithAnimation(views: [whenToDoHourDetailView, blurredBackground], display: false)
    }
    
    
}

extension WhenVC: CreateEventProtocol {
    func updateEventInfo() {
        updateEventDate()
    }
}


