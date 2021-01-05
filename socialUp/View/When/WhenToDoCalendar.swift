//
//  WhenToDoCalendar.swift
//  SocialUp
//
//  Created by Metin Öztürk on 6.12.2018.
//  Copyright © 2018 Metin Ozturk. All rights reserved.
//

import UIKit

protocol WhenToDoCalendarDelegate : class {
    func presentWhenToDoHourDetailPopUp()
    func sendDayDataToHourDetailView(dayData: [[Bool]])
}


class WhenToDoCalendar : UIView {
        
    weak var delegateOfWhenToDoCalendar : WhenToDoCalendarDelegate?
    
    @IBOutlet weak var whenToDoCalendar: UICollectionView!
    
    
    @IBOutlet weak var monthAndYearLabel: UILabel!
    
    @IBOutlet weak var futureButton: UIButton!
    @IBOutlet weak var pastButton: UIButton!

    let currentDayMonthYear : [String : Int] = {
        let date = Date()
        let calendar = NSCalendar.current
        
        let currentDate = calendar.dateComponents(in: .autoupdatingCurrent, from: date)
        
        return ["day" : currentDate.day!, "month" : currentDate.month!, "year" : currentDate.year!]
    }()
    
    let cvInterimSpacing : CGFloat = 5
    let cvMinimumLineSpacing : CGFloat = 5
    let numberOfItemsPerRow : CGFloat = 7
    let reuseIdentifier = "WhenToDoCalendar"

    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var isSelectedPreviously = Array(repeating: Array(repeating: false, count: 31), count: 12)
    var isConfirmed = Array(repeating: Array(repeating: false, count: 31), count: 12)
    
    // PROPERTY OBSERVERS
    var whichDayNameToStart : String = ""
    var whichDayToStart : Int = 0
    var currentMonth : Int?
    var currentYear : Int?
    
    var numberOfMonthsPassed : Int = 0 {
        didSet {
            numberOfMonthsPassed = numberOfMonthsPassed < 0 ? 0 : numberOfMonthsPassed
            numberOfMonthsPassed = numberOfMonthsPassed > 5 ? 5 : numberOfMonthsPassed
            
            whichDayNameToStart = dayNamesOfMonths(monthsPassed: numberOfMonthsPassed)
            whichDayToStart = computeWhichDayToStart()
            monthAndYearLabel.text = getMonthNameAndYear(monthsPassed: numberOfMonthsPassed)["Month"] as! String + ", " + String(getMonthNameAndYear(monthsPassed: numberOfMonthsPassed)["Year"] as! Int)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeNib()
        
        whenToDoCalendar.allowsMultipleSelection = true
        whenToDoCalendar.delegate = self
        whenToDoCalendar.dataSource = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        longPressGesture.minimumPressDuration = 1
        addGestureRecognizer(longPressGesture)
        
        whenToDoCalendar.register(UINib(nibName: "WhenToDoCalendarCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    private func dayNamesOfMonths(monthsPassed: Int) -> String {

        let calendar = Calendar.current
        let interimComponents = getInterimDateComponents(monthsPassed: monthsPassed)
        
        let startOfMonth = calendar.date(from:interimComponents)!
        let firstDayOfMonth = calendar.date(byAdding: .day, value: 0, to: startOfMonth)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: firstDayOfMonth!)
    }
    
    private func numberOfDaysInMonth(monthsPassed: Int) -> Int {
        let calendar = Calendar.current
        let interimComponents = getInterimDateComponents(monthsPassed: monthsPassed)
        
        let range = calendar.range(of: .day, in: .month, for: calendar.date(from: interimComponents)! )!
        return range.upperBound - 1
    }
    
    private func getMonthNameAndYear(monthsPassed: Int) -> [String: Any] {
        let interimComponents = getInterimDateComponents(monthsPassed: monthsPassed)
        
        let monthName : String = {
            switch interimComponents.month! {
            case 1:
                return "January"
            case 2:
                return "February"
            case 3:
                return "March"
            case 4:
                return "April"
            case 5:
                return "May"
            case 6:
                return "June"
            case 7:
                return "July"
            case 8:
                return "August"
            case 9:
                return "September"
            case 10:
                return "October"
            case 11:
                return "November"
            case 12:
                return "December"
            default:
                return "Error"
            }
        }()
        
        return ["Month" : monthName, "Year" : interimComponents.year! ]
    }
    
    func getInterimDateComponents(monthsPassed: Int) -> DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        
        let interimDate = calendar.date(byAdding: .month, value: monthsPassed, to: calendar.date(from: components)!)
        let interimComponents = calendar.dateComponents([.month, .year], from: interimDate!)
        return interimComponents
    }
    
    private func computeWhichDayToStart() -> Int {
        switch whichDayNameToStart {
            
        case "Monday":
            return 0
        case "Tuesday":
            return 1
        case "Wednesday":
            return 2
        case "Thursday":
            return 3
        case "Friday":
            return 4
        case "Saturday":
            return 5
        case "Sunday":
            return 6
        default:
            return 9
        }
    }
    
    
    private func checkWhichDaysAreTapped() -> [Int] {
        var indexItem = 7 + whichDayToStart
        var interimArray = [Int]()
        
        while indexItem < numberOfDaysInMonth(monthsPassed: numberOfMonthsPassed) + 7 + whichDayToStart {
            let cell = collectionView(whenToDoCalendar, cellForItemAt: IndexPath(row: indexItem, section: 0)) as! WhenToDoCalendarCell
            if cell.isSelected == true {
                interimArray.append(indexItem)
            }
            indexItem += 1
        }

        return interimArray
        
    }
    @IBAction func goToFuture(_ sender: UIButton) {
        numberOfMonthsPassed += 1
        whenToDoCalendar.reloadData()
    }
    
    @IBAction func goToPast(_ sender: UIButton) {
        numberOfMonthsPassed -= 1
        whenToDoCalendar.reloadData()
    }
    
    @objc private func longPressed(_ sender: UILongPressGestureRecognizer){
        
//        let dayData = checkWhichDaysAreTapped().count > 0 ? checkWhichDaysAreTapped() : nil
        
        let dataToBeTransferred = isSelectedPreviously
        
        var doesContainTrue = false
        
        for array in dataToBeTransferred {
            doesContainTrue = array.contains(true) ? true : false
            if doesContainTrue { break }
        }
        
        if  doesContainTrue == true {
            delegateOfWhenToDoCalendar?.sendDayDataToHourDetailView(dayData: dataToBeTransferred)
            delegateOfWhenToDoCalendar?.presentWhenToDoHourDetailPopUp()
        }
    }
    
}



extension WhenToDoCalendar : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if numberOfMonthsPassed == section {
            return 7 + whichDayToStart + numberOfDaysInMonth(monthsPassed: numberOfMonthsPassed)
        }
        else {
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: IndexPath(row: indexPath.row, section: numberOfMonthsPassed)) as! WhenToDoCalendarCell
        
        let dayOffSet = numberOfMonthsPassed == 0 ? currentDayMonthYear["day"]! - 1 : 0
        
        if indexPath.row < 7 {
            cell.dayLabel.text = daysOfWeek[indexPath.row]
            cell.dayLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 8)
            cell.dayLabel.backgroundColor = .lightGray
            cell.backgroundColor = .clear
            cell.isUserInteractionEnabled = false
            
        } else if indexPath.row  >= whichDayToStart + 7 + dayOffSet {
            cell.isUserInteractionEnabled = true
            cell.dayLabel.text = String(indexPath.row - 6 - whichDayToStart)
            cell.dayLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 12)
            cell.dayLabel.textAlignment = .center
            cell.dayLabel.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 0.6)
            cell.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 0.2)
            
            let rowIndex = indexPath.row - whichDayToStart - 7
            
            if isConfirmed[numberOfMonthsPassed][rowIndex] == true {
                cell.isSelected = true
                cell.dayLabel.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 0.4)
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            } else if isSelectedPreviously[numberOfMonthsPassed][rowIndex] == true {
                cell.isSelected = true
                cell.dayLabel.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.4)
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            }
            
        } else {
            cell.alpha = 0.2
            cell.isUserInteractionEnabled = false
            cell.backgroundColor = .lightGray
            cell.dayLabel.text = ""
            cell.dayLabel.backgroundColor = .darkGray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: numberOfMonthsPassed)) as! WhenToDoCalendarCell
        
        cell.dayLabel.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.6)
        isSelectedPreviously[numberOfMonthsPassed][indexPath.row - 7 - whichDayToStart] = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: numberOfMonthsPassed)) as! WhenToDoCalendarCell
        
        cell.dayLabel.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 0.6)
        isSelectedPreviously[numberOfMonthsPassed][indexPath.row - 7 - whichDayToStart] = false
        isConfirmed[numberOfMonthsPassed][indexPath.row - 7 - whichDayToStart] = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (self.frame.width - (numberOfItemsPerRow - 1) * cvInterimSpacing) / numberOfItemsPerRow
        let height = (0.5 * self.frame.height - 5 * cvMinimumLineSpacing ) / 6
        return CGSize(width: width, height: height)
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cvInterimSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cvMinimumLineSpacing
    }
}
