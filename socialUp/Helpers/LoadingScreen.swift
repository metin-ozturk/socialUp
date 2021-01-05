//
//  LoadingScreen.swift
//  socialUp
//
//  Created by Metin Öztürk on 21.12.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

class LoadingScreen: UIView {
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeNib()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeNib()
        self.translatesAutoresizingMaskIntoConstraints = false
    }

}
