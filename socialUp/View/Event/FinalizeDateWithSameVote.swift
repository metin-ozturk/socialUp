//
//  FinalizeDateWithSameVote.swift
//  socialUp
//
//  Created by Metin Öztürk on 20.12.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

protocol FinalizeDateWithSameVoteDelegate : class {
    func onDateConfirmed(confirmedDate: String)
}

class FinalizeDateWithSameVote : UIView {
    
    weak var delegate : FinalizeDateWithSameVoteDelegate?
    @IBOutlet private weak var finalizeDateLabel: UILabel!
    @IBOutlet private weak var finalizeDatePickerView: UIPickerView!
    @IBOutlet private weak var finalizeDateConfirmButton: UIButton!
    
    var datesToPickFrom = [String]() {
        willSet(newDate) {
            let dateAsReadable = newDate.map({Event.convertEventDateToReadableFormat(eventDate: $0)})
            datesToPickFromReadable = dateAsReadable
        }
    }
    
    var datesToPickFromReadable = [String]() {
        didSet {
            finalizeDatePickerView.reloadAllComponents()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeNib()
        
        finalizeDatePickerView.delegate = self
        finalizeDatePickerView.dataSource = self
    }
    
    @IBAction func finalizeDateConfirmButtonTapped(_ sender: UIButton) {
        let confirmedIndex = finalizeDatePickerView.selectedRow(inComponent: 0)
        let confirmedDate = datesToPickFrom[confirmedIndex]
        delegate?.onDateConfirmed(confirmedDate: confirmedDate)
    }
}

extension FinalizeDateWithSameVote : UIPickerViewDelegate, UIPickerViewDataSource {
    // NUMBER OF COLUMNS
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // NUMBER OF ROWS
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datesToPickFromReadable.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return datesToPickFromReadable[row]
    }
    
}
