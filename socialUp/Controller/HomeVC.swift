//
//  Home.swift
//  SocialUp
//
//  Created by Metin Öztürk on 24.12.2018.
//  Copyright © 2018 Metin Ozturk. All rights reserved.
//

// FIX: CARRY OVER EFFECTS WHEN STH TYPED INTO VIEW'S TEXT FIELD AND VIEW DISMISSED, IT MAY PERSIST NEXT TIME VIEW IS BEING PRESENTED

//FIX: WHAT HAPPENS TO CLOUD MESSAGING TOKEN WHEN USERS DONT COMPLETE SIGN UP INFO

import UIKit
import Firebase

import GoogleSignIn

import FBSDKLoginKit

import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

enum ShadedBackgroundTag : Int {
    case allowsToDismissViewWhenTapped = 67
    case loadingScreen = 68
    case nothingHappensWhenTapped
}

private enum SignUpMethod : String {
    case Facebook = "Facebook"
    case Google = "Google"
    case Password = "Email"
    case Phone = "Phone"
}

class HomeVC: UIViewController {
    
    @IBOutlet private weak var googleSignInButton: UIButton!
    @IBOutlet private weak var facebookSignInButton: UIButton!
    @IBOutlet private weak var signInWithPasswordButton: UIButton!
    
    
    @IBOutlet private weak var signInWithPassword: SignInWithPassword!
    @IBOutlet private weak var homeShadedBackground: UIVisualEffectView!
    @IBOutlet private weak var completeInformationView: SignUpCompleteInformation!

    
    private var existingSignUpMethod : SignUpMethod? = nil
    private var newSignUpMethod : SignUpMethod? = nil
    private var newSignUpMethodAuthCredential : AuthCredential? = nil
        
    private lazy var fireStore = Firestore.firestore()
    private let imagePicker = UIImagePickerController()
    
    
    private var isUserLoggedIn : Bool? =  false {
        didSet {
            if let isLoggedIn = isUserLoggedIn, isLoggedIn {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    private lazy var facebookSignInManager = LoginManager()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        signInWithPassword.delegate = self
        completeInformationView.delegate = self
        
        homeShadedBackground.contentView.tag = ShadedBackgroundTag.allowsToDismissViewWhenTapped.rawValue
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        Settings.isAdvertiserIDCollectionEnabled = true 
        Settings.isAutoLogAppEventsEnabled = true
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    //    @objc func handleKeyboardNotification(_ notification: NSNotification) {
    //
    //        if let userInfo = notification.userInfo {
    //            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
    //            loginViewTopConstraint.constant -= keyboardFrame.height / 2
    //            loginViewBottomConstraint.constant -= keyboardFrame.height / 2
    //        }
    //    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        
        if touch?.view?.tag == ShadedBackgroundTag.allowsToDismissViewWhenTapped.rawValue {
            view.displayOrHideViewsWithAnimation(views: [homeShadedBackground, completeInformationView, signInWithPassword], display: false)

            // DISMISSES KEYBOARD
            signInWithPassword.endEditing(false)
        }
    }
    
    private func receiveCloudMessagingToken() {
        InstanceID.instanceID().instanceID { (result, error) in
            guard let userID = Auth.auth().currentUser?.uid else {
                print("Error while receiving Cloud Messaging Token: Couldn't get UserID")
                return
            }
          if let error = error {
            print("Error fetching remote instance ID: \(error.localizedDescription)")
            return
          } else if let result = result {
            Firestore.firestore().collection("users").document(userID).updateData(["CloudMessagingToken" : result.token])
          }
        }

    }
    

}

extension HomeVC : SignUpCompleteInformationDelegate {
    func presentImagePicker() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func confirmButtonTapped(authResult: AuthDataResult) {
        self.view.showLoadingScreen()
        User.updateUserProfile(authResult: authResult, completeInformationView: completeInformationView) {
            self.isUserLoggedIn = true
            self.receiveCloudMessagingToken()
            self.view.removeLoadingScreen()
            self.completeInformationView.isHidden = true
            self.homeShadedBackground.isHidden = true
            self.clearLinkAccountVariables()
        }
    }
}

extension HomeVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            completeInformationView.profilePhotoImageView.image = image
        }

        dismiss(animated: true, completion: nil)
    }

}

extension HomeVC {
    private func signInWithCredential(credential: AuthCredential, currentSignUpMethod: SignUpMethod) {
        self.view.showLoadingScreen()
        Auth.auth().signIn(with: credential) { (authResult, error) in
            self.view.removeLoadingScreen()
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                    switch errorCode {
                    case .accountExistsWithDifferentCredential:
                        print("ACCOUNT EXIST WITH DIFFERENT CREDENTIAL")
                    default:
                        print("UNIDENTIFIED ERROR OCCURED WHILE SIGNING IN TO FIREBASE")
                    }
                self.clearLinkAccountVariables()
                return
                }
            
            // SUCCESS - FIREBASE SIGN IN
            
            if (authResult?.additionalUserInfo?.isNewUser == true) {
                self.fulfillNewUserInfo(authResult: authResult, currentSignUpMethod: currentSignUpMethod)
            } else {
                self.linkAccounts(retrievedAuthResult: authResult, currentSignUpMethod: currentSignUpMethod)
            }

            
        }
    }
    
    private func linkAccounts(retrievedAuthResult: AuthDataResult?, currentSignUpMethod : SignUpMethod) {
        if let newSignUpMethodAuthCredential = self.newSignUpMethodAuthCredential,
            let newSignUpMethod = self.newSignUpMethod,
            let existingSignUpMethod = self.existingSignUpMethod {
            view.showLoadingScreen()
            Auth.auth().currentUser?.link(with: newSignUpMethodAuthCredential, completion: { (result, error) in
                self.clearLinkAccountVariables()
                self.view.removeLoadingScreen()

                if let error = error {
                    self.present(UIAlertController.showErrorAlert(message: "While linking your \(newSignUpMethod.rawValue) and \(existingSignUpMethod.rawValue) accounts, an error occurred."), animated: true, completion: nil)
                    print(error.localizedDescription)
                    return
                }
                
                self.present(UIAlertController.showInformationAlert(message: "\(newSignUpMethod.rawValue) and \(existingSignUpMethod.rawValue) accounts have been linked.") {
                    self.checkIfCompleteUserInfoCreated(authResult: result) { (infoExists) in
                        if infoExists == false {
                            self.fulfillNewUserInfo(authResult: result, currentSignUpMethod: newSignUpMethod)
                        } else {
                            self.isUserLoggedIn = true
                            self.receiveCloudMessagingToken()
                            self.clearLinkAccountVariables()
                        }
                    }
                }, animated: true)
            })
        } else {
            checkIfCompleteUserInfoCreated(authResult: retrievedAuthResult) { (infoExists) in
                if infoExists == false {
                    self.fulfillNewUserInfo(authResult: retrievedAuthResult, currentSignUpMethod: currentSignUpMethod)
                } else {
                    self.receiveCloudMessagingToken()
                    self.isUserLoggedIn = true
                    self.clearLinkAccountVariables()
                }
            }
        }
    }
    
    
    private func showAlertToLinkAccounts(authCredential: AuthCredential, existingSignUpMethod: SignUpMethod, newSignUpMethod: SignUpMethod) {
        
        self.newSignUpMethod = newSignUpMethod
        self.existingSignUpMethod = existingSignUpMethod
        self.newSignUpMethodAuthCredential = authCredential
        
        let alert = UIAlertController(title: "Link Accounts", message: "Previously you signed in with your \(existingSignUpMethod.rawValue) account. Do you want to link your \(newSignUpMethod.rawValue) account with your \(existingSignUpMethod.rawValue) account?", preferredStyle: UIAlertController.Style.alert)
    
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action) in
            switch existingSignUpMethod {
            case .Google:
                GIDSignIn.sharedInstance().signIn()
            case .Facebook:
                self.signInWithFacebookAndLinkAccountsIfNecessary()
            case .Password:
                self.signInWithPassword.isHidden = false
            default:
                print("An Error Occurred While Showing Alert To Link Accounts")
                self.clearLinkAccountVariables()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func clearLinkAccountVariables() {
        existingSignUpMethod = nil
        newSignUpMethod = nil
        newSignUpMethodAuthCredential = nil
    }
    
    private func checkIfCompleteUserInfoCreated(authResult: AuthDataResult?, infoExists: @escaping (Bool) -> Void) {
        guard let userID = authResult?.user.uid else { return }
        self.view.showLoadingScreen()

        Firestore.firestore().collection("users").document(userID).getDocument { (snap, error) in
            self.view.removeLoadingScreen()

            if let error = error {
                print(error.localizedDescription)
                return
            }
            infoExists(snap?.exists ?? false)
            
        }
    }
    
    private func fulfillNewUserInfo(authResult: AuthDataResult?, currentSignUpMethod: SignUpMethod) {
        guard let user = authResult?.user else { return }
        
        var photoUrl : String?
        var name : String?
        
        completeInformationView.clearView()

        if currentSignUpMethod == .Facebook {
            photoUrl = (authResult?.additionalUserInfo?.profile?["picture"] as! [String : [String:Any]])["data"]?["url"] as? String
            name = authResult?.additionalUserInfo?.profile?["first_name"] as? String
        } else if currentSignUpMethod == .Google {
            photoUrl = authResult?.additionalUserInfo?.profile?["picture"] as? String
            name = authResult?.additionalUserInfo?.profile?["name"] as? String
        }
        

        if let photoUrl = photoUrl {
            completeInformationView.profilePhotoImageView.downloaded(from: photoUrl, contentMode: UIView.ContentMode.scaleAspectFit)
        } else {
            completeInformationView.profilePhotoImageView.image = UIImage(named: "imagePlaceholder")
        }

        completeInformationView.emailTextField.text = user.email
        completeInformationView.nameTextField.text = name
        completeInformationView.authResult = authResult
        
        view.displayOrHideViewsWithAnimation(views: [completeInformationView, homeShadedBackground], display: true)
    }
}


extension HomeVC {
    @IBAction func facebookSignInButtonTapped(_ sender: Any) {
        signInWithFacebookAndLinkAccountsIfNecessary()
    }
    
    private func signInWithFacebookAndLinkAccountsIfNecessary() {
        signInWithFacebook { result in
            guard let accessToken = result?.token?.tokenString else { return }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
            
            self.getFacebookEmail(accessToken: accessToken, completion: { (email) in
                self.view.showLoadingScreen()
                Auth.auth().fetchSignInMethods(forEmail: email, completion: { (signInMethods, error) in
                    self.view.removeLoadingScreen()
                    if let error = error {
                        print(error.localizedDescription)
                        self.clearLinkAccountVariables()
                        return
                    }
                                        
                    if signInMethods?.contains("google.com") == true && signInMethods?.contains("facebook.com") == false  {
                        self.showAlertToLinkAccounts(authCredential: credential, existingSignUpMethod: .Google, newSignUpMethod: .Facebook)
                    } else if signInMethods?.contains("password") == true && signInMethods?.contains("facebook.com") == false {
                        self.showAlertToLinkAccounts(authCredential: credential, existingSignUpMethod: .Password, newSignUpMethod: .Facebook)
                    } else {
                        self.signInWithCredential(credential: credential, currentSignUpMethod: .Facebook)
                    }
                })
            })
            
        }
    }
    
    private func signInWithFacebook(afterSignIn:((LoginManagerLoginResult?) -> Void)? = nil) {
        view.showLoadingScreen()
        facebookSignInManager.logIn(permissions: ["email", "public_profile"], from: self) { (result, error) in
            self.view.removeLoadingScreen()
            if let error = error {
                print(error.localizedDescription)
                self.clearLinkAccountVariables()
                return
            } else if result?.isCancelled ?? false {
                self.clearLinkAccountVariables()
                return
            }
            
            
            guard let afterSignIn = afterSignIn else { return }
            afterSignIn(result)
            
        }
    }
    
    private func getFacebookEmail(accessToken: String, completion: @escaping (String) -> Void) {
        let request = GraphRequest(graphPath: "/me", parameters: ["fields" : "id,name,email"], tokenString: accessToken, version: nil, httpMethod: HTTPMethod.get)
        let connection = GraphRequestConnection()
        
        connection.add(request, completionHandler: { (connection, result, error) in
            if let error = error {
                print(error.localizedDescription)
                self.clearLinkAccountVariables()
                return
            }
            
            let result = result as! [String : String]
            guard let email = result["email"] else { return }
            completion(email)
            connection?.cancel()
            self.view.removeLoadingScreen()
        })
        
        view.showLoadingScreen()
        connection.start()
    }
    
    
}


extension HomeVC : GIDSignInDelegate {
    @IBAction func googleSignInButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            clearLinkAccountVariables()
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        view.showLoadingScreen()
        Auth.auth().fetchSignInMethods(forEmail: user.profile.email) { (signInMethods, error) in
            self.view.removeLoadingScreen()
            if let error = error {
                print(error.localizedDescription)
                self.clearLinkAccountVariables()
                return
            }
            
            if (signInMethods?.contains("facebook.com") == true && signInMethods?.contains("google.com") == false) {
                self.showAlertToLinkAccounts(authCredential: credential, existingSignUpMethod: .Facebook, newSignUpMethod: .Google)
            } else if (signInMethods?.contains("password") == true && signInMethods?.contains("google.com") == false) {
                self.showAlertToLinkAccounts(authCredential: credential, existingSignUpMethod: .Password, newSignUpMethod: .Google)
            } else {
                self.signInWithCredential(credential: credential, currentSignUpMethod: .Google)
            }
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Signed Out From Google")
    }
    
    
}

extension HomeVC : SignInWithPasswordDelegate {
    
    @IBAction func passwordSignInButtonTapped(_ sender: UIButton) {
        signInWithPassword.clearView()
        view.displayOrHideViewsWithAnimation(views: [signInWithPassword, homeShadedBackground], display: true)

    }
    
    func googleSignInWith() {
        present(UIAlertController.showInformationAlert(message: "You previously sign in with your Google account. Please sign in to continue.") {
            self.view.displayOrHideViewsWithAnimation(views: [self.homeShadedBackground, self.signInWithPassword], display: false) {
                GIDSignIn.sharedInstance().signIn()
            }
        }, animated: true, completion: nil)

    }
    
    func facebookSignInWith() {
        present(UIAlertController.showInformationAlert(message: "You previously sign in with your Facebook account. Please sign in to continue.") {
            self.view.displayOrHideViewsWithAnimation(views: [self.homeShadedBackground, self.signInWithPassword], display: false) {
                self.signInWithFacebook()
            }
        }, animated: true, completion: nil)
    }
    
    func onFinish(authResult: AuthDataResult){
        self.linkAccounts(retrievedAuthResult: authResult, currentSignUpMethod: .Password)
    }
    
    func onCreateUser(authResult: AuthDataResult) {
        fulfillNewUserInfo(authResult: authResult, currentSignUpMethod: SignUpMethod.Password)
    }
    

}






