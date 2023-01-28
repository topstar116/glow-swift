//
//  AuthViewController.swift
//  glow
//
//  Created by Dreams on 22/06/20.
//  Copyright © 2020 Dreams. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import AuthenticationServices
import Firebase
import GoogleSignIn

class AuthViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var faceBookButton: UIButton!
    @IBOutlet weak var signInWithGoogleButton: UIButton!
    var user: User!
    
    static func getInstance() -> AuthViewController {
        let viewController = Constants.Storyboard.LOGIN.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 13.0, *) {
            self.appleButton.isHidden = false
        } else {
            self.appleButton.isHidden = true
            // Fallback on earlier versions
        }
    }    
    
    //MARK:- FBLogin
    
    
    func faceBookLogin(){
        
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logOut()
        
        fbLoginManager.logIn(permissions:["email"], from: self, handler: { (result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print(error?.localizedDescription ?? "")
            }
            else if (result?.isCancelled)!
            {
                // Handle cancellations
                print(error?.localizedDescription ?? "")
            }
            else
            {
                let fbloginresult : LoginManagerLoginResult = result!
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                    // fbLoginManager.logOut()
                }
            }
        })
        
    }
    
    func signUpApiCall() {
        if self.emailTextField.text?.isEmpty ?? true {
            Utility.alert(message: "Please enter your email.")
        } else if self.passwordTextField.text?.isEmpty ?? true {
            Utility.alert(message: "Please enter your password.")
        } else if self.passwordTextField.text != self.confirmPasswordTextField.text {
            Utility.alert(message: "Password doesn't match.")
        } else {
            let param = ["email" : self.emailTextField.text ,
                         "password" : self.passwordTextField.text]
            Utility.showProgress()
            AuthRequest.signUpWithEmail(param: param as [String : Any]) { (success, response, error) in
                Utility.dismissProgress()
                if error == nil {
                    Utility.alert(message: response ?? "", button1: "OK") { (index) in
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    Utility.alert(message: response ?? "")
                }
            }
        }
    }
    
    func getFBUserData(){
        var fbId : String = ""
        // var fbEmail : String = ""
        var fbName : String = ""
        // var fbPickUrl : String = ""
        
        if((AccessToken.current) != nil) {
            GraphRequest(graphPath: "me", parameters: ["fields": "id,email,name"]).start { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    print("Result111:\(String(describing: result)) "as Any)
                }
                let dict = result as! NSDictionary
                print("FB Email1st:\(dict)")
                
                fbId = dict["id"] as! String
                fbName = dict["name"] as! String
                //fbEmail = dict["email"] as? String ?? ""
                //get user picture url from dictionary
                // fbPickUrl = (((dict["picture"] as? [String: Any])?["data"] as? [String:Any])?["url"] as? String ?? "")
                
                // print("FB ID: \(fbId)\n FB Email:\(fbEmail) \n FbName:\(fbName) \n FBProfileUrl:\(fbPickUrl)\n")
                let param = ["facebookId" : fbId,
                             "name": fbName]
                Utility.showProgress()
                AuthRequest.loginAPI(param: param, loginIndex: 1) { (success, user, error) in
                    Utility.dismissProgress()
                    if error == nil {
                        UserDefaultHelper.saveUser(user: user!)
                        AppData.sharedInstance.user = user
                        Loggdinuser.set(true, forKey: USERLOGIN)
                        Loggdinuser.set(user?.profilePic, forKey: USERIMAGE)
                        Loggdinuser.set(user?.token ?? "", forKey: ACCESSTOKEN)
                        self.navigateToHomeScreen()
                    } else {
                        Utility.alert(message: error?.localizedDescription ?? "Opps!")
                    }
                }
            }
        }
        
    }
    
    //MARK:- Apple Login
    
    @available(iOS 13.0, *)
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13.0, *)
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    //MARK:- Google login
    
    func navigateToHomeScreen() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "navigation") as? UINavigationController
        AppDelegate.sharedInstance.window?.rootViewController = vc
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func signInWithEmail(_ sender: UIButton) {
        self.signUpApiCall()
    }
    
    
    @IBAction func signinWithPhoneNumber(_ sender: UIButton) {
        GIDSignIn.sharedInstance.signIn(with: GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? ""), presenting: self) { user, error in
            if let error = error {
                print("\(error.localizedDescription)")
                
            } else {
                // Perform any operations on signed in user here.
                
                let userId = user?.userID ?? ""                 // For client-side use only
                let fullName = user?.profile?.name ?? ""
                let param = ["googleId" : userId,
                             "name": fullName]
                Utility.showProgress()
                AuthRequest.loginAPI(param: param, loginIndex: 0) { (success, user, error) in
                    Utility.dismissProgress()
                    if error == nil {
                        UserDefaultHelper.saveUser(user: user!)
                        Loggdinuser.set(true, forKey: USERLOGIN)
                        Loggdinuser.set(user?.profilePic, forKey: USERIMAGE)
                        Loggdinuser.set(user?.token ?? "", forKey: ACCESSTOKEN)
                        AppData.sharedInstance.user = user
                        self.navigateToHomeScreen()
                    } else {
                        Utility.alert(message: error?.localizedDescription ?? "Opps!")
                    }
                }
            }
        }
    }
    
    @IBAction func signinWithFaceBook(_ sender: UIButton) {
        self.faceBookLogin()
    }
    
    @available(iOS 13.0, *)
    @IBAction func signinWithApple(_ sender: UIButton) {
        self.handleAuthorizationAppleIDButtonPress()
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension AuthViewController: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            let param = ["appleId" : userIdentifier] as [String : Any]
            AuthRequest.loginAPI(param: param, loginIndex: 2) { (success, user, error) in
                Utility.dismissProgress()
                if error == nil {
                    UserDefaultHelper.saveUser(user: user!)
                    AppData.sharedInstance.user = user
                    Loggdinuser.set(true, forKey: USERLOGIN)
                    Loggdinuser.set(user?.profilePic, forKey: USERIMAGE)
                    Loggdinuser.set(user?.token ?? "", forKey: ACCESSTOKEN)
                    self.navigateToHomeScreen()
                } else {
                    Utility.alert(message: error?.localizedDescription ?? "Opps!")
                }
            }
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserInKeychain(userIdentifier)
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.example.apple-samplecode.juice", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        self.navigateToHomeScreen()
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - Tag: did_complete_error
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
