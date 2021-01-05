//
//  Extensions.swift
//  socialUp
//
//  Created by Metin Öztürk on 16.04.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit

extension UIView {
    static func setupLabels(labelText: String) -> UILabel {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 0.8)
        label.textColor = .black
        label.text = labelText
        return label
    }
    
    static func setupTextFields(textFieldPlaceholder: String, isPassword: Bool) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = textFieldPlaceholder
        textField.autocapitalizationType = .none
        if isPassword { textField.isSecureTextEntry = true }
        return textField
    }
    
    static func setupButtons(buttonText: String, targetVC: UIViewController? = nil, targetView: UIView? = nil, selector: Selector, backgroundColor: UIColor? = nil, titleColor: UIColor? = nil, titleFont: UIFont? = nil) -> UIButton {
        let button = UIButton(frame: .zero)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(buttonText, for: UIControl.State.normal)
        button.backgroundColor = backgroundColor == nil ? .lightGray : backgroundColor
        button.titleLabel?.font = titleFont == nil ? UIFont.systemFont(ofSize: 12) : titleFont
        
        if titleColor != nil { button.setTitleColor(titleColor, for: UIControl.State.normal) }
        
        if targetVC != nil {
            button.addTarget(targetVC, action: selector, for: UIControl.Event.touchUpInside)
        } else if targetView != nil {
            button.addTarget(targetView, action: selector, for: UIControl.Event.touchUpInside)
        }
        return button
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension UIAlertController {
    static func showErrorAlert(message: String, completion: (() -> Void)? = nil) -> UIAlertController{
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.destructive, handler: { (action) in
            guard let completion = completion else { return }
            completion()
        }))
        
        return alert
    }
    
    static func showInformationAlert(message: String, completion: (() -> Void)? = nil) -> UIAlertController{
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { (action) in
            guard let completion = completion else { return }
            completion()
        }))
        
        return alert
    }
    
    
}

extension UIView {
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of:self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func initializeNib() {
        let view = self.loadNib()
        
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
    
    func showLoadingScreen() {
        let loadingScreen = LoadingScreen(frame: .zero)
        self.addSubview(loadingScreen)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: loadingScreen, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: loadingScreen, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: loadingScreen, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: loadingScreen, attribute: .bottom, multiplier: 1, constant: 0)
        ])
    }
    
    func removeLoadingScreen() {
        self.subviews.first(where: {$0 is LoadingScreen})?.removeFromSuperview()
    }
    
    func displayOrHideViewsWithAnimation(views: [UIView?], display: Bool, completion: (() -> Void)? = nil) {
        // Set showView to true if you want to make views unhidden
        UIView.transition(with: self, duration: 0.25, options: [.showHideTransitionViews, .transitionCrossDissolve], animations: {
            views.forEach { (viewToBeShowed) in
                guard let viewToBeShowed = viewToBeShowed else { return }
                viewToBeShowed.isHidden = !display
                
            }
        }) { animationResult in
            if let completion = completion, animationResult == true {
                completion()
            }
            
        }
    }
}
