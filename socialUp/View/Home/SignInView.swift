//
//  LoginView.swift
//  SocialUp
//
//  Created by Metin Öztürk on 24.12.2018.
//  Copyright © 2018 Metin Ozturk. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol SignInViewDelegate : class {
    func loggedInSuccessfully()
    func loginUnsuccessful(error: Error)
    func loginWithFacebookByEmail()
    func loginWithGoogleByEmail()
}

class SignInView : UIView {
    
    weak var delegateOfSignInView : SignInViewDelegate?
    
    private let emailLabel = setupLabels(labelText: "Email:")
    private let passwordLabel = setupLabels(labelText: "Password:")
    
    private let emailTextField = setupTextFields(textFieldPlaceholder: "Type Your Email", isPassword: false)
    private let passwordTextField = setupTextFields(textFieldPlaceholder: "Type Your Password", isPassword: true)
    
    lazy var confirmButton = UIView.setupButtons(buttonText: "Confirm?", targetView: self, selector: #selector(confirmButtonTapped(_:)))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUsernameLabel()
        setupUsernameTextField()
        setupPasswordLabel()
        setupPasswordTextField()
        setupConfirmButton()
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetView() {
        confirmButton.backgroundColor = .lightGray
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @objc func confirmButtonTapped(_ sender: UIButton){
        confirmButton.isUserInteractionEnabled = false

        Auth.auth().fetchSignInMethods(forEmail: emailTextField.text!) { (provider, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let currentProvider = provider, currentProvider.contains("google.com") {
                self.delegateOfSignInView?.loginWithGoogleByEmail()
                
            } else if let currentProvider = provider, currentProvider.contains("facebook.com") {
                self.delegateOfSignInView?.loginWithFacebookByEmail()
                
                
            } else {
                Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                    if let error = error {
                        self.delegateOfSignInView?.loginUnsuccessful(error: error)
                        return
                    }
                    self.confirmButton.backgroundColor = .green
                    self.delegateOfSignInView?.loggedInSuccessfully()
                }
            }
        }
    }
    
    private func setupUsernameLabel() {
        addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: emailLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: emailLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.2, constant: 0),
            NSLayoutConstraint(item: emailLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: emailLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
    }
    
    private func setupUsernameTextField() {
        addSubview(emailTextField)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: emailTextField, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.2, constant: 0),
            NSLayoutConstraint(item: emailTextField, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.4, constant: 0),
            NSLayoutConstraint(item: emailTextField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: emailTextField, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
    }
    
    private func setupPasswordLabel() {
        addSubview(passwordLabel)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: passwordLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.4, constant: 0),
            NSLayoutConstraint(item: passwordLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.6, constant: 0),
            NSLayoutConstraint(item: passwordLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: passwordLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
        
    }
    
    private func setupPasswordTextField() {
        addSubview(passwordTextField)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: passwordTextField, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.6, constant: 0),
            NSLayoutConstraint(item: passwordTextField, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.8, constant: 0),
            NSLayoutConstraint(item: passwordTextField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: passwordTextField, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
    }
    
    private func setupConfirmButton() {
        addSubview(confirmButton)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: confirmButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.8, constant: 0),
            NSLayoutConstraint(item: confirmButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: confirmButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: confirmButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
    }
    
}
