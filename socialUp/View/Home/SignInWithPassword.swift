//
//  SignUpWithPasswordView.swift
//  socialUp
//
//  Created by Metin Öztürk on 31.08.2019.
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol SignInWithPasswordDelegate: class {
    func googleSignInWith()
    func facebookSignInWith()
    func onFinish(authResult: AuthDataResult)
    func onCreateUser(authResult: AuthDataResult)
}

class SignInWithPassword : UIView {
    
    weak var delegate : SignInWithPasswordDelegate?
    
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeNib()
    }
    
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let email = emailAddressTextField.text
            , let password = passwordTextField.text else { return }
        
        superview?.showLoadingScreen()
        Auth.auth().fetchSignInMethods(forEmail: email) { (signInMethods, error) in
            self.superview?.removeLoadingScreen()
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if (signInMethods?.contains("google.com") == true) {
                self.delegate?.googleSignInWith()
            } else if (signInMethods?.contains("facebook.com") == true) {
                self.delegate?.facebookSignInWith()
            } else if signInMethods == nil {
                self.signUpWithPassword(email: email, password: password)
            } else {
                self.signUpButton.setTitle("Sign In", for: UIControl.State.normal)
                self.signInWithPassword(email: email, password: password)
            }
        }
    }

    private func signUpWithPassword(email: String, password: String) {
        superview?.showLoadingScreen()
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            self.superview?.removeLoadingScreen()
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let result = result else { return }
            self.delegate?.onCreateUser(authResult: result)
            
        }
    }
    
    private func signInWithPassword(email: String, password: String) {
        superview?.showLoadingScreen()
        Auth.auth().signIn(withEmail: email, password: password, completion: { (result, error) in
            self.superview?.removeLoadingScreen()

            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let result = result else { return }
            self.delegate?.onFinish(authResult: result)
        })
    }
    
    func clearView() {
        [passwordTextField, emailAddressTextField].forEach { (textField) in
            textField?.text = ""
            textField?.resignFirstResponder()
        }
    }
    
}
