//
//  SignUpView.swift
//  SocialUp
//
//  Created by Metin Öztürk on 24.12.2018.
//  Copyright © 2018 Metin Ozturk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

protocol SignUpViewDelegate : class {
    func signedInSuccessfully(email: String, username: String, authResult: AuthDataResult?)
    func loginWithFacebookByEmail()
    func loginWithGoogleByEmail()
}

class SignUpView : UIView {
    
    weak var delegateOfSignUpView : SignUpViewDelegate?
    
    private let usernameLabel = setupLabels(labelText: "Username:")
    private let emailLabel = setupLabels(labelText: "Email:")
    private let passworldLabel = setupLabels(labelText: "Password:")
    
    private let usernameTextField = setupTextFields(textFieldPlaceholder: "Type Your Username", isPassword: false)
    private let emailTextField = setupTextFields(textFieldPlaceholder: "Type Your Email", isPassword: false)
    private let passwordTextField = setupTextFields(textFieldPlaceholder: "Type Your Password", isPassword: true)
    
    private lazy var confirmButton = UIView.setupButtons(buttonText: "Confirm?", targetView: self, selector: #selector(confirmButtonTapped(_:)))
    
    private lazy var fireStore = Firestore.firestore()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUsernameLabelAndTextField()
        setupEmailLabelAndTextField()
        setupPasswordLabelAndTextField()
        setupConfirmButton()
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
    }
    
    @objc func confirmButtonTapped(_ sender: UIButton) {
        var newUser = User()
        newUser.name = usernameTextField.text
        newUser.email = emailTextField.text
        
        Auth.auth().fetchSignInMethods(forEmail: emailTextField.text!) { (provider, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let currentProvider = provider, currentProvider.contains("google.com") {
                self.delegateOfSignUpView?.loginWithGoogleByEmail()
                
                
            } else if let currentProvider = provider, currentProvider.contains("facebook.com") {
                self.delegateOfSignUpView?.loginWithFacebookByEmail()
                
            } else {
                Auth.auth().createUser(withEmail: self.emailTextField.text!, password:  self.passwordTextField.text!) { (authResult, error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    self.confirmButton.backgroundColor = .green
                    self.delegateOfSignUpView?.signedInSuccessfully(email: self.emailTextField.text!, username: self.usernameTextField.text!, authResult: authResult)
                }
            }
        }
        
    }
    
    func resetView() {
        confirmButton.backgroundColor = .lightGray
        usernameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    
    private func setupUsernameLabelAndTextField() {
        addSubview(usernameLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: usernameLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: usernameLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.1, constant: 0),
            NSLayoutConstraint(item: usernameLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: usernameLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
        
        addSubview(usernameTextField)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: usernameTextField, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.15, constant: 0),
            NSLayoutConstraint(item: usernameTextField, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.25, constant: 0),
            NSLayoutConstraint(item: usernameTextField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: usernameTextField, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
    }
    
    private func setupEmailLabelAndTextField() {
        addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: emailLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.3, constant: 0),
            NSLayoutConstraint(item: emailLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.4, constant: 0),
            NSLayoutConstraint(item: emailLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: emailLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
        
        addSubview(emailTextField)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: emailTextField, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.45, constant: 0),
            NSLayoutConstraint(item: emailTextField, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.55, constant: 0),
            NSLayoutConstraint(item: emailTextField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: emailTextField, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
    }
    
    private func setupPasswordLabelAndTextField() {
        addSubview(passworldLabel)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: passworldLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.6, constant: 0),
            NSLayoutConstraint(item: passworldLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.7, constant: 0),
            NSLayoutConstraint(item: passworldLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: passworldLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
        
        addSubview(passwordTextField)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: passwordTextField, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.75, constant: 0),
            NSLayoutConstraint(item: passwordTextField, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.85, constant: 0),
            NSLayoutConstraint(item: passwordTextField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: passwordTextField, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
    }
    
    private func setupConfirmButton() {
        addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: confirmButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.85, constant: 0),
            NSLayoutConstraint(item: confirmButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: confirmButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: confirmButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
