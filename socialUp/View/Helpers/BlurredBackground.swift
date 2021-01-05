//
//  ShadedBackground.swift
//  socialUp
//
//  Created by Metin Öztürk on 4.12.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

@IBDesignable
class BlurredBackground : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeNib()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeNib()
    }
    
    private func initializeNib() {
        let view = self.loadNib()
        
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
}
