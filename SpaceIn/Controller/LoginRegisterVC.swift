//
//  LoginViewController.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import Firebase
import GeoFire
import OneSignal

enum LoginRegisterState {
    case login
    case register
}
let AgreeText = "By signing up, you are agreeing to our Terms of Service and Privacy Policy"
class LoginRegisterVC : UIViewController {
    
    static let imageWidth = CGFloat(100)
    static let textFieldHeights = CGFloat(40)
    static var buttonHeights = CGFloat(50)
    static let closeButtonWidthHeight = CGFloat(40)
    static let closeButtonTopPadding = CGFloat(20)
    static let closeButtonSidePadding = CGFloat(-20)

    
    //PersistentViews
    var backgroundImageView = UIImageView(frame: CGRect.zero)
    var logoImageView = UIImageView(frame: CGRect.zero)
    let emailTextField = ToplessTextField(frame: CGRect.zero)
    let passwordTextField = ToplessTextField(frame: CGRect.zero)
    let signupLoginButton = RoundedButton(filledIn: false, color: StyleGuideManager.loginButtonBorderColor)
    let orLabel = UILabel(frame: CGRect.zero)
    let socialLoginButton = RoundedButton(filledIn: false, color: StyleGuideManager.loginButtonBorderColor)
    let bottomButtonsView = UIView(frame: CGRect.zero)
    let switchLoginRegisterButton = UIButton(type: .custom)
    let closeButton = UIButton(frame: CGRect.zero)
    var spinner : UIActivityIndicatorView?
    var spinnerConstraints = [NSLayoutConstraint]()
    
    //Register only views
    let fullNameTextField = ToplessTextField(frame: CGRect.zero)
    let confirmPasswordTextField = ToplessTextField(frame: CGRect.zero)
    
    //Login only views
    let divider = UILabel()
    let forgotPasswordButton = UIButton(type: .custom)
    let loginFont = StyleGuideManager.sharedInstance.loginPageFont()
    
    var state = LoginRegisterState.login
    
    var forgotPasswordVC: ForgotPasswordVC?
    
    
    
    lazy var agreeTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        
        
        //MARK: handle text attribute
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let agreeAttributedString = NSMutableAttributedString(string: AgreeText, attributes: [NSForegroundColorAttributeName: UIColor.white, NSParagraphStyleAttributeName: style])
        
        agreeAttributedString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 15)], range: NSRange(location: 0, length: 38))
        
        let termsRange = NSRange(location: 39, length: 16)
        let termsAttribute = ["terms": "terms of value", NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightBold), NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue] as [String : Any]
        agreeAttributedString.addAttributes(termsAttribute, range: termsRange)
        
        
        agreeAttributedString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 15)], range: NSRange(location: 55, length: 5))
        
        
        let policyRange = NSRange(location: 60, length: 14)
        let policyAttribute = ["policy": "policy of value", NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightBold), NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue] as [String : Any]
        agreeAttributedString.addAttributes(policyAttribute, range: policyRange)
        
        
        textView.attributedText = agreeAttributedString
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        textView.isUserInteractionEnabled = true
        textView.addGestureRecognizer(tap)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    //MARK: handle tapgesture for terms and policy
    
    func handleTapGesture(sender: UITapGestureRecognizer) {
        
        let textView = sender.view as! UITextView
        let layoutManager = textView.layoutManager
        
        var location = sender.location(in: textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        
        let characterIndex = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if characterIndex < textView.textStorage.length {
            // print the character index
            print("character index: \(characterIndex)")
            
            // print the character at the index
            let myRange = NSRange(location: characterIndex, length: 1)
            let substring = (textView.attributedText.string as NSString).substring(with: myRange)
            print("character at index: \(substring)")
            
            // check if the tap location has a certain attribute
            let termsName = "terms"
            let termsValue = textView.attributedText.attribute(termsName, at: characterIndex, effectiveRange: nil) as? String
            
            let policyName = "policy"
            let policyValue = textView.attributedText.attribute(policyName, at: characterIndex, effectiveRange: nil) as? String
            
            if let termsValue = termsValue {
                print("You tapped on \(termsName) and the value is: \(termsValue)")
                
                let agreementController = AgreementController()
                agreementController.controllerStatus = .authController
                agreementController.agreementStatus = .terms
                present(agreementController, animated: true, completion: nil)
            } else if let policyValue = policyValue {
                print("You tapped on \(policyName) and the value is: \(policyValue)")
                
                let agreementController = AgreementController()
                agreementController.controllerStatus = .authController
                agreementController.agreementStatus = .policy
                present(agreementController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.userIsSignedIn() == true {
            self.goAway()
        }
        
        self.addButtonTargets()
        self.setTextFieldDelegates()
        FirebaseHelper.setUIDelegateTo(delegate: self)
        self.addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.addConstantViews()
        self.view.removeConstraints(self.view.constraints)
        self.view.backgroundColor = UIColor.white
        
        if self.shouldLoadRegisterView() {
            self.layoutRegisterView()
        } else {
            self.layoutSignInView()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }

//MARK: Initialization code
    
    private func addButtonTargets() {
        self.socialLoginButton.addTarget(self, action: #selector(self.socialLoginPressed), for: .touchUpInside)
        self.signupLoginButton.addTarget(self, action: #selector(self.loginRegisterPressed), for: .touchUpInside)
        self.switchLoginRegisterButton.addTarget(self, action: #selector(self.switchState), for: .touchUpInside)
        self.forgotPasswordButton.addTarget(self, action: #selector(self.forgotPasswordPressed), for: .touchUpInside)
        self.closeButton.addTarget(self, action: #selector(self.closeButtonPressed), for: .touchUpInside)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.goAway), name: .DidSetCurrentUser, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.failedSocialLogin), name: .DidFailGoogleLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.failedAuth), name: .DidFailAuthentication, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.googleErrorOccurred), name: .DidFailLogin, object: nil)
    }
    
    fileprivate func userIsSignedIn() -> Bool {
        return SpaceInUser.userIsLoggedIn()
    }
    
    func goAway() {
        OperationQueue.main.addOperation {
            [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func shouldLoadRegisterView() -> Bool {
        return self.state == .register
    }
    
    func loginRegisterPressed() {
        if self.state == .register {
            self.registerIfWeCan()
        } else {
            self.loginIfWeCan()
        }
    }
    
//MARK: Buttons Pressed
    
    func socialLoginPressed() {
        self.addSpinner()
        GIDSignIn.sharedInstance().signIn()
    }
    
    func forgotPasswordPressed() {
        self.doForgotPassword()
    }
    
    func closeButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func loginIfWeCan() {
        let loginStateIsValid = self.loginStateIsValid()
        if loginStateIsValid.0 == false {
            self.presentErrorMessageWithAlert(alert: loginStateIsValid.1!)
        } else {
            self.login()
        }
    }
    
    
    private func login() {
        guard let email = emailTextField.text else {
            self.presentErrorMessageWithAlert(alert: AlertMessage.invalidEmail())
            return
        }
        
        guard let password = passwordTextField.text else {
            self.presentErrorMessageWithAlert(alert: AlertMessage.invalidPassword())
            return
        }
        
        self.addSpinner()
        
        FirebaseHelper.loginUser(email: email, password: password, completion: { fbUser, returntype in
            self.stopSpinner()
            if returntype != .Success {
                self.handleFireBaseReturnTypre(returnType: returntype)
            } else {
                if fbUser != nil {
                    
                    SpaceInUser.current = SpaceInUser(fireBaseUser: fbUser!, coordinate: nil)
                    
                    var profileChange = ProfileChanges()
                    profileChange.isLogIn = true
                    
                    guard let uid = Auth.auth().currentUser?.uid else {
                        return
                    }
                    
                    let geoFireRef = Database.database().reference().child("users").child(uid).child("user_location")
                    let geoFire = GeoFire(firebaseRef: geoFireRef)
                    
//                    Global.currentUserLocation = LocationManager.sharedInstance.userLocation!
                    geoFire?.setLocation(Global.currentUserLocation, forKey: uid)
                    
                    
                    FirebaseHelper.makeProfileChanges(changes: profileChange, for: (SpaceInUser.current?.uid)!, completion: { (returnType) in
                        if returnType == FirebaseReturnType.Success {
                            
                            print("success to save user location")
                            Global.isLogIn = true
                            UserDefaults.standard.set(true, forKey: "IsLogIn")
                            UserDefaults.standard.synchronize()
                            
                        } else {
                            print("Fail to save user location")
                        }
                    }) { (notUsed, AlsoNotUsedString) in
                        
                    }
                    
                    SpaceInUser.current?.loadInformationFromServer()
                } else {
                    print("if there is no error there must be a fb user. SOMETHING WENT WRONG")
                }
                
                self.goAway()
            }
        })
        
    }
    
    private func registerIfWeCan() {
        let registerStateIsValid = self.registerStateIsValid()
        if registerStateIsValid.0 == false {
            self.presentErrorMessageWithAlert(alert: registerStateIsValid.1!)
        } else {
            self.register()
        }
    }
    
    private func register() {
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        let fullName = self.fullNameTextField.text
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let userID = status.subscriptionStatus.userId
        
        self.addSpinner()
        
        FirebaseHelper.createUser(name: fullName!, email: email!, password: password!, pushToken: userID!, completion: { name, createdUserEmail, createdUserUID, pushToken, fbReturnType in
            self.stopSpinner()
            if fbReturnType != .Success {
                self.handleFireBaseReturnTypre(returnType: fbReturnType)
            } else {
                self.loginIfWeCan()
            }
        })
    }
    
    
    //MARK: Validation
    private func formIsValid() -> (Bool, AlertMessage?) {
        return self.state == .register ? self.registerStateIsValid() : self.loginStateIsValid()
    }
    
    private func registerStateIsValid() -> (Bool, AlertMessage?) {
        if !LoginRegisterVC.isValidEmailAddress(email: self.emailTextField.text!) {
            
            return (false, AlertMessage.invalidEmail())
            
        } else if !self.validateFullName(name: self.fullNameTextField.text!){
            
            return (false, AlertMessage.invalidName())
            
        } else if !self.passwordShortEnough(text: self.passwordTextField.text!){
        
            return (false, AlertMessage.passwordTooLong())
            
        }  else if !self.passwordIsLongEnough(text: self.passwordTextField.text!) {
            
            return (false, AlertMessage.passwordTooShort())
            
        } else if self.passwordTextField.text != self.confirmPasswordTextField.text {
            
            return (false, AlertMessage.passwordsDontMatch())
            
        } else {
            
            return (true, nil)
        }
    }
    
    private func loginStateIsValid() -> (Bool, AlertMessage?) {
        return LoginRegisterVC.isValidEmailAddress(email: self.emailTextField.text!) ? (true, nil) : (false, AlertMessage.invalidEmail())
    }
    
    class func isValidEmailAddress(email: String) -> Bool {
        if email.isValidString() {
            if !email.contains("@") {
                return false
            }
            
            if email.characters.count < 6 {
                return false
            }
            
            if !email.contains(".") {
                return false
            }
        } else {
            return false
        }
        
        return true
    }
    
    private func validateFullName(name: String) -> Bool {
        return name.characters.count > 2
    }

    
    private func passwordIsLongEnough(text: String) -> Bool {
        return text.characters.count > 5
    }
    
    private func passwordShortEnough(text: String) -> Bool {
        return text.characters.count < 15
    }
    
    
    //MARK: State management
    func switchState() {
        let stateToSwitchTo = self.state == .register ? LoginRegisterState.login : LoginRegisterState.register
        self.switchToState(state: stateToSwitchTo)
    }
    
    private func switchToState(state: LoginRegisterState) {
        if state == self.state {return}
        self.state = state
        switch self.state {
        case .register:
            self.layoutRegisterView()
            break
        case .login:
            self.layoutSignInView()
            break
        }
    }
    
    //MARK: Error handling
    private func handleFireBaseReturnTypre(returnType: FirebaseReturnType) {
        self.stopSpinner()
        let alertMessage = AlertMessage.alertMessageForFireBaseReturnType(returnType: returnType)
        let alertController = UIAlertController(title: alertMessage.alertTitle, message: alertMessage.alertSubtitle, preferredStyle: .alert)
        if alertMessage.actionButton1Title.isValidString() {
            alertController.addAction(UIAlertAction(title: alertMessage.actionButton1Title, style: .default, handler: nil))
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func failedSocialLogin() {
        OperationQueue.main.addOperation {
            [weak self] in
            self?.stopSpinner()
            self?.presentErrorMessageWithAlert(alert: AlertMessage.failedSocialLogin())
        }
    }
    
    func failedAuth() {
        OperationQueue.main.addOperation {
            [weak self] in
            self?.stopSpinner()
            self?.presentErrorMessageWithAlert(alert: AlertMessage.failedAuth())
        }
    }
    
    func googleErrorOccurred() {
        OperationQueue.main.addOperation {
            [weak self] in
            self?.stopSpinner()
            self?.presentErrorMessageWithAlert(alert: AlertMessage.failedAuth())
        }
    }
    
    private func presentErrorMessageWithAlert(alert: AlertMessage) {
        let alertController = UIAlertController(title: alert.alertTitle, message: alert.alertSubtitle, preferredStyle: .alert)
        
        if alert.actionButton1Title.isValidString() {
            alertController.addAction(UIAlertAction(title: alert.actionButton1Title, style: .default, handler: nil))
        }
        
        if alert.actionButton2title != nil {
            if alert.actionButton2title!.isValidString() {
                alertController.addAction(UIAlertAction(title: alert.actionButton2title!, style: .default, handler: nil))
            }
            //breadcrumb- we need to handle actions for secondary calls
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}
    
extension LoginRegisterVC : GIDSignInUIDelegate {
    
}


//MARK: - Forgot Password
extension LoginRegisterVC: ForgotPasswordVCDelegate {
    fileprivate func doForgotPassword() {
        if self.forgotPasswordVC == nil {
            self.forgotPasswordVC = ForgotPasswordVC()
            self.forgotPasswordVC?.delegate = self
        }
        
        self.present(self.forgotPasswordVC!, animated: false, completion: nil)
    }
    
    func closeForgotPasswordVC() {
        self.forgotPasswordVC?.dismiss(animated: true, completion: nil)
    }
}

//how to call fb
//        FirebaseHelper.createUser(name: "name", email: "email", password: "password", completion: { name, email, uid, fbReturnType in

//})
