//
//  ForgotPasswordVC.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import UIKit

protocol ForgotPasswordVCDelegate {
    func closeForgotPasswordVC()
}

class ForgotPasswordVC: UIViewController {
    //MARK: - Class Constants
    static let closeButtonWidthHeight = CGFloat(40)
    
    //Constants
    let closeButton = UIButton()
    let logoImageView = UIImageView()
    let troubleLogginInLabel = UILabel()
    let instructionsLabel = UILabel()
    let emailTextField = ToplessTextField()
    let sendEmailButton = RoundedButton(filledIn: true, color: StyleGuideManager.loginButtonBorderColor)
    var delegate: ForgotPasswordVCDelegate?
    var activityIndicator: UIActivityIndicatorView?
    
    var didSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setup()
    }
}


//MARK: - UI
extension ForgotPasswordVC {
    
    func setup() {
        if self.didSetup == false {
            self.addSubviewsAndSetThemAsConstrainable()
            self.setupSubviews()

        }
        
        self.didSetup = true
    }
    
    fileprivate func addSubviewsAndSetThemAsConstrainable() {
        let viewsToAdd = [self.closeButton, self.logoImageView, self.troubleLogginInLabel, self.instructionsLabel, self.emailTextField, self.sendEmailButton]
        
        for view in viewsToAdd {
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
    }
    
    fileprivate func setupSubviews() {
        self.setupCloseButton()
        self.setupLogoImageView()
        self.setupTroubleLoggingInLabel()
        self.setupInstructionsLabel()
        self.setupEmailTextField()
        self.setupButton()
    }
    
    fileprivate func setupCloseButton() {
        let backImage = UIImage(named: AssetName.backButton.rawValue)
        self.closeButton.setImage(backImage, for: .normal)
        self.closeButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        self.closeButton.imageView?.contentMode = .scaleAspectFit
        
        self.constrainCloseButton()
        
        self.closeButton.addTarget(self, action: #selector(self.closeButtonPressed), for: .touchUpInside)
    }
    
    private func constrainCloseButton() {
        self.closeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: LoginRegisterVC.closeButtonSidePadding).isActive = true
        self.closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: LoginRegisterVC.closeButtonWidthHeight).isActive = true
        self.closeButton.constrainWidthAndHeightToValueAndActivate(value: LoginRegisterVC.closeButtonWidthHeight)
    }

    fileprivate func setupLogoImageView() {
        self.logoImageView.image = UIImage(named: AssetName.logoColored.rawValue)
        self.logoImageView.contentMode = .scaleAspectFit
        
        self.constrainLogo()
    }
    
    fileprivate func constrainLogo() {
        self.logoImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.logoImageView.topAnchor.constraint(equalTo: self.closeButton.bottomAnchor, constant: 20).isActive = true
        self.logoImageView.widthAnchor.constraint(equalToConstant: LoginRegisterVC.imageWidth + 10).isActive = true
        self.logoImageView.heightAnchor.constraint(equalToConstant: LoginRegisterVC.imageWidth  + 40).isActive = true
    }
    
    fileprivate func setupTroubleLoggingInLabel() {
        self.troubleLogginInLabel.text = SpaceinCopy.forgotPasswordTitle.rawValue
        self.troubleLogginInLabel.font = StyleGuideManager.sharedInstance.forgotPasswordPageFont()
        self.troubleLogginInLabel.textColor = StyleGuideManager.forgotPasswordTextColor
        self.troubleLogginInLabel.textAlignment = .center
        
        self.constrainTroubleLoggingInLabel()
    }
    
    fileprivate func constrainTroubleLoggingInLabel() {
        self.troubleLogginInLabel.topAnchor.constraint(equalTo: self.logoImageView.bottomAnchor, constant: 45).isActive = true
        self.troubleLogginInLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.troubleLogginInLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.troubleLogginInLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    fileprivate func setupInstructionsLabel() {
        self.instructionsLabel.text = SpaceinCopy.forgotPasswordSubtitle.rawValue
        self.instructionsLabel.textAlignment = .center
        self.instructionsLabel.font = StyleGuideManager.sharedInstance.forgotPasswordPageFont()
        self.instructionsLabel.textColor = StyleGuideManager.forgotPasswordTextColor
        self.instructionsLabel.numberOfLines = 3
        self.instructionsLabel.lineBreakMode = .byWordWrapping
        self.constrainInstructionsLabel()
        
    }
    
    fileprivate func constrainInstructionsLabel() {
        self.instructionsLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40).isActive = true
        self.instructionsLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -40).isActive = true
        self.instructionsLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.instructionsLabel.topAnchor.constraint(equalTo: self.troubleLogginInLabel.bottomAnchor, constant: 15).isActive = true
    }
    
    fileprivate func setupEmailTextField() {
        self.emailTextField.borderColor = StyleGuideManager.registerTextFieldTextColor
        self.emailTextField.selectedBorderColor = StyleGuideManager.registerTextFieldSelectedColor

        let placeholderTextColor = StyleGuideManager.registerPlaceholderTextColor
        let placeholderText = "email"
        let font = StyleGuideManager.sharedInstance.forgotPasswordPageFont()
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSForegroundColorAttributeName: placeholderTextColor, NSFontAttributeName: font])
        self.emailTextField.textColor = StyleGuideManager.registerTextFieldTextColor
        self.constrainEmailTextField()

    }
    
    fileprivate func constrainEmailTextField() {
        self.emailTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        self.emailTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        self.emailTextField.topAnchor.constraint(equalTo: self.instructionsLabel.bottomAnchor, constant: 40).isActive = true
        self.emailTextField.heightAnchor.constraint(equalToConstant: LoginRegisterVC.textFieldHeights).isActive = true
        self.emailTextField.toplessTextfieldDelegate = self
        
    }
    
    fileprivate func setupButton() {
        let backgroundImage = UIImage(named: AssetName.signUpButtonGradient.rawValue)
        self.sendEmailButton.setFilledInState(filledIn: true)
        self.sendEmailButton.setBackgroundImage(backgroundImage, for: .normal)
        self.sendEmailButton.setTitle(SpaceinCopy.forgotPasswordPageButtonCopy.rawValue, for: .normal)
        self.sendEmailButton.addTarget(self, action: #selector(self.sendButtonPressed), for: .touchUpInside)
        self.constrainButton()
    }
    
    fileprivate func constrainButton() {
        self.sendEmailButton.topAnchor.constraint(equalTo: self.emailTextField.bottomAnchor, constant: 50).isActive = true
        self.sendEmailButton.widthAnchor.constraint(equalTo: self.emailTextField.widthAnchor).isActive = true
        self.sendEmailButton.heightAnchor.constraint(equalToConstant: LoginRegisterVC.buttonHeights).isActive = true
        self.sendEmailButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    fileprivate func addSpinner() {
        self.view.isUserInteractionEnabled = false
        if self.activityIndicator == nil {
            self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            self.view.addSubview(self.activityIndicator!)
            self.activityIndicator?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            self.activityIndicator?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            self.activityIndicator?.constrainWidthAndHeightToValueAndActivate(value: 50)
        }
        self.activityIndicator?.startAnimating()
        self.activityIndicator?.isHidden = false
        self.activityIndicator?.hidesWhenStopped = true

        //breadcrumb
    }
    
    fileprivate func stopSpinner() {
        self.view.isUserInteractionEnabled = true
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.isHidden = true
    }
}


//MARK: - Targets
extension ForgotPasswordVC {
    func closeButtonPressed() {
        self.delegate?.closeForgotPasswordVC()
    }
    
    func sendButtonPressed() {
        if !LoginRegisterVC.isValidEmailAddress(email: self.emailTextField.text!) {
            self.presentInvalidEmail()
        } else {
            self.sendResetEmailIfWeCan()
        }
    }
}


//MARK: - Send To Firebase and Alerts
extension ForgotPasswordVC {
    
    func presentInvalidEmail() {
        let alertMessage = AlertMessage.invalidEmail()
        let alertController = UIAlertController(title: alertMessage.alertTitle, message: alertMessage.alertSubtitle!, preferredStyle: .alert)
        let okAction = UIAlertAction(title: alertMessage.actionButton1Title, style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendResetEmailIfWeCan() {
        self.addSpinner()
        FirebaseHelper.sendResetEmailTo(email: self.emailTextField.text!, completion: { returnType in
            if returnType == .Success {
                self.presentEmailSentAndDismiss()
            } else {
                self.presentAlertMessage(alertMessage: AlertMessage.alertMessageForFireBaseReturnType(returnType: returnType))
            }
        })
    }
    
    func presentAlertMessage(alertMessage: AlertMessage) {
        self.stopSpinner()
        
        let alertController = UIAlertController(title: alertMessage.alertTitle, message: alertMessage.alertSubtitle!, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: alertMessage.actionButton1Title, style: .default, handler: nil))
            
        if let alertAction2 = alertMessage.actionButton2title {
            alertController.addAction(UIAlertAction(title: alertAction2, style: .default, handler: nil))
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentEmailSentAndDismiss() {
        self.stopSpinner()
        let alertMessage = AlertMessage.passwordResetSent()
        let alertController = UIAlertController(title: alertMessage.alertTitle, message: alertMessage.alertSubtitle!, preferredStyle: .alert)
        let okAction = UIAlertAction(title: alertMessage.actionButton1Title, style: .default) { (action) in
            self.delegate?.closeForgotPasswordVC()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}



//MARK: - TextFieldDelegate
extension ForgotPasswordVC: ToplessTextFieldDelegate {
    func toplessTextFieldDidBeginEditing() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func handleTap(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.view.removeGestureRecognizer(gesture)
    }
    
    //These funcs are stubbed because we don't need them.
    func didDismissKeyboard(textField: ToplessTextField) {}
    func toplessTextFieldDidEndEdting() {}


}
