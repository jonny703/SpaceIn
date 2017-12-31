//
//  LoginRegisterVC+UI.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit

extension LoginRegisterVC { //UI calls
    //MARK: - Initial UI Setup(Login + Register)
    
    

    
    func addConstantViews() {
        self.addConstantSubviews()
        self.setViewsAsConstrainable()
        self.setFonts()
        self.orLabel.textAlignment = .center
        self.orLabel.text = "or"
        
        self.emailTextField.autocapitalizationType = .none
        
        self.signupLoginButton.setTitleColor(UIColor.white, for: .normal)
        self.socialLoginButton.setTitleColor(UIColor.white, for: .normal)
        
        self.signupLoginButton.setTitleColor(UIColor.gray, for: .highlighted)
        self.socialLoginButton.setTitleColor(UIColor.gray, for: .highlighted)
        
        self.forgotPasswordButton.setTitle("Forgot Password", for: .normal)
        self.forgotPasswordButton.setTitleColor(UIColor.gray, for: .highlighted)
        
        self.switchLoginRegisterButton.setTitleColor(UIColor.gray, for: .highlighted)
        self.setTextFieldKeyboardSettings()
        
        let backImage = UIImage(named: AssetName.backButton.rawValue)
        self.closeButton.setImage(backImage, for: .normal)
        self.closeButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        self.closeButton.imageView?.contentMode = .scaleAspectFit

    }
    
    fileprivate func addConstantSubviews() {
        self.view.addSubview(self.backgroundImageView)
        self.view.addSubview(self.logoImageView)
        self.view.addSubview(self.emailTextField)
        self.view.addSubview(self.passwordTextField)
        self.view.addSubview(self.signupLoginButton)
        self.view.addSubview(self.orLabel)
        self.view.addSubview(self.socialLoginButton)
        self.view.addSubview(self.bottomButtonsView)
        self.view.addSubview(self.closeButton)
        self.bottomButtonsView.addSubview(self.switchLoginRegisterButton)
    }
    
    fileprivate func setViewsAsConstrainable() {
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.signupLoginButton.translatesAutoresizingMaskIntoConstraints = false
        self.orLabel.translatesAutoresizingMaskIntoConstraints = false
        self.socialLoginButton.translatesAutoresizingMaskIntoConstraints = false
        self.switchLoginRegisterButton.translatesAutoresizingMaskIntoConstraints = false
        self.bottomButtonsView.translatesAutoresizingMaskIntoConstraints = false
        self.fullNameTextField.translatesAutoresizingMaskIntoConstraints = false
        self.confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.divider.translatesAutoresizingMaskIntoConstraints = false
        self.forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: - Shared UI Calls (Login + Register)
    fileprivate func setFonts() {
        self.signupLoginButton.titleLabel?.font = self.loginFont
        self.socialLoginButton.titleLabel?.font = self.loginFont
        self.orLabel.font = self.loginFont
        self.divider.font = StyleGuideManager.sharedInstance.loginFontLarge()
        self.forgotPasswordButton.titleLabel?.font = StyleGuideManager.sharedInstance.loginPageSmallFont()
        self.switchLoginRegisterButton.titleLabel?.font = StyleGuideManager.sharedInstance.loginPageSmallFont()
    }
    
    fileprivate func setTextFieldKeyboardSettings() {
        self.emailTextField.keyboardType = .emailAddress
        self.emailTextField.returnKeyType = .next
        self.emailTextField.autocorrectionType = .no
        
        self.fullNameTextField.autocorrectionType = .no
        self.fullNameTextField.keyboardType = .default
        self.fullNameTextField.returnKeyType = .next
        
        self.passwordTextField.autocorrectionType = .no
        self.confirmPasswordTextField.autocorrectionType = .no
        self.passwordTextField.isSecureTextEntry = true
        self.confirmPasswordTextField.isSecureTextEntry = true
        self.confirmPasswordTextField.returnKeyType = .done
        
        self.passwordTextField.keyboardType = .default
        self.confirmPasswordTextField.keyboardType = .default
    }
    
    
    func layoutBackgroundImageView() {
        self.backgroundImageView.contentMode = .scaleToFill
        self.backgroundImageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: -20).isActive = true
        self.backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -20).isActive = true
        self.backgroundImageView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 20).isActive = true
        self.backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 20).isActive = true
    }
    
    fileprivate func updateSubviewsForStateChange() {
        self.backgroundImageView.image = self.state == .register ?  nil : AssetManager.imageForAssetName(name: .loginBackground)
        
        self.logoImageView.image = self.state == .register ?  AssetManager.imageForAssetName(name: AssetName.logoColored) : AssetManager.imageForAssetName(name: AssetName.logoWhite)

        
        self.backgroundImageView.backgroundColor = UIColor.clear
        self.updateButtonsForStateChange()
        self.updateTextFieldsForStateChange()
        
        self.orLabel.textColor = self.state == .register ? StyleGuideManager.registerPageTextColor : StyleGuideManager.loginPageTextColor
    }
    
    private func updateButtonsForStateChange() {
        self.socialLoginButton.setFilledInState(filledIn: self.state == .register)
        self.signupLoginButton.setFilledInState(filledIn: self.state == .register)
        
        let signUpTitle = self.state == .register ? "Sign Up" : "Sign In"
        self.signupLoginButton.setTitle(signUpTitle, for: .normal)
        
        let socialTitle = self.state == .register ? "Sign up with Google" : "Sign in with Google"
        self.socialLoginButton.setTitle(socialTitle, for: .normal)
        
        let backgroundImage = self.state == .register ? UIImage(named: AssetName.signUpButtonGradient.rawValue) : UIImage()
        self.signupLoginButton.setBackgroundImage(backgroundImage, for: .normal)
        self.socialLoginButton.setBackgroundImage(backgroundImage, for: .normal)

        let switchTitle = self.state == .register ? "Sign in" : "Sign Up"
        self.switchLoginRegisterButton.setTitle(switchTitle, for: .normal)
        
        let switchColor = self.state == .register ? StyleGuideManager.registerPageTextColor : StyleGuideManager.loginPageTextColor
        self.switchLoginRegisterButton.setTitleColor(switchColor, for: .normal)
        
        self.passwordTextField.returnKeyType = self.state == .login ? .done : .next
    }
    
    private func updateTextFieldsForStateChange() {
        self.setColorsForTextField(textField: self.emailTextField, withPlaceHolerText: "Email")
        self.setColorsForTextField(textField: self.fullNameTextField, withPlaceHolerText: "Name")
        self.setColorsForTextField(textField: self.passwordTextField, withPlaceHolerText: "Password")
        self.setColorsForTextField(textField: self.confirmPasswordTextField, withPlaceHolerText: "Confirm Password")
    }
    
    
    fileprivate func setColorsForTextField(textField: ToplessTextField, withPlaceHolerText placeholderText: String) {
        textField.borderColor = self.state == .register ? StyleGuideManager.registerTextFieldDefaultColor : StyleGuideManager.loginTextFieldDefaultColor
        textField.selectedBorderColor = self.state == .register ? StyleGuideManager.registerTextFieldSelectedColor : StyleGuideManager.loginTextFieldSelectedColor
        
        let placeholderTextColor = self.state == .register ? StyleGuideManager.registerPlaceholderTextColor : StyleGuideManager.loginPlaceholderTextColor
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSForegroundColorAttributeName: placeholderTextColor, NSFontAttributeName: self.loginFont])
        textField.textColor = self.state == .register ?  StyleGuideManager.registerTextFieldTextColor : StyleGuideManager.loginTextFieldTextColor
    }
    
    
    //MARK: - Register Calls
    func layoutRegisterView() {

        self.view.removeConstraints(self.view.constraints)
        self.removeLoginSpecificViews()
        self.addRegisterSpecificSubviews()
        self.layoutBackgroundImageView()
        self.updateSubviewsForStateChange()
        self.constrainRegisterView()
        self.constrainSpinner()
        UIApplication.shared.isStatusBarHidden = true
        UIApplication.shared.statusBarStyle = .default
    }
    
    fileprivate func removeLoginSpecificViews() {
        self.forgotPasswordButton.removeFromSuperview()
        self.divider.removeFromSuperview()
        self.bottomButtonsView.removeConstraints(self.bottomButtonsView.constraints)
    }
    
    private func addRegisterSpecificSubviews() {
        let viewsToAdd = [self.fullNameTextField, self.confirmPasswordTextField]
        for view in viewsToAdd {
            self.view.addSubview(view)
        }
    }
    
    fileprivate func removeRegisterSpecificViews() {
        self.confirmPasswordTextField.removeFromSuperview()
        self.fullNameTextField.removeFromSuperview()
    }
    
    fileprivate func constrainRegisterView() {
        let widthForViews = self.view.frame.width * 0.71
        let paddingBetweenTextFields = CGFloat(32)
        
        let textFields = [self.passwordTextField, self.fullNameTextField, self.emailTextField, self.passwordTextField, self.confirmPasswordTextField]
        
        for centeredView in textFields {
            centeredView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            centeredView.widthAnchor.constraint(equalToConstant: widthForViews).isActive = true
            centeredView.heightAnchor.constraint(equalToConstant: LoginRegisterVC.textFieldHeights).isActive = true
        }
        
        self.closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: LoginRegisterVC.closeButtonWidthHeight).isActive = true
        self.closeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: LoginRegisterVC.closeButtonSidePadding).isActive = true
        self.closeButton.constrainWidthAndHeightToValueAndActivate(value: LoginRegisterVC.closeButtonWidthHeight)
        
       
        //setup vertical spacing
        self.passwordTextField.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -5).isActive = true
        self.fullNameTextField.bottomAnchor.constraint(equalTo: self.passwordTextField.topAnchor, constant: -paddingBetweenTextFields).isActive = true
        self.emailTextField.bottomAnchor.constraint(equalTo: self.fullNameTextField.topAnchor, constant: -paddingBetweenTextFields).isActive = true
        self.confirmPasswordTextField.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant: paddingBetweenTextFields).isActive = true
        
        self.logoImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.logoImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        self.logoImageView.bottomAnchor.constraint(equalTo: self.emailTextField.topAnchor, constant: -10).isActive = true
        self.logoImageView.widthAnchor.constraint(equalToConstant: LoginRegisterVC.imageWidth).isActive = true
        
        self.signupLoginButton.topAnchor.constraint(equalTo: self.confirmPasswordTextField.bottomAnchor, constant: 40).isActive = true
        self.signupLoginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.signupLoginButton.heightAnchor.constraint(equalToConstant: LoginRegisterVC.buttonHeights).isActive = true
        self.signupLoginButton.widthAnchor.constraint(equalTo: self.emailTextField.widthAnchor).isActive = true
        
        let topPadding = CGFloat(22)
        
        self.orLabel.topAnchor.constraint(equalTo: signupLoginButton.bottomAnchor, constant: topPadding).isActive = true
        self.orLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.orLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.orLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        self.socialLoginButton.topAnchor.constraint(equalTo: self.orLabel.bottomAnchor, constant: topPadding).isActive = true
        self.socialLoginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.socialLoginButton.widthAnchor.constraint(equalTo: self.signupLoginButton.widthAnchor).isActive = true
        self.socialLoginButton.heightAnchor.constraint(equalTo: self.signupLoginButton.heightAnchor).isActive = true
        
        self.bottomButtonsView.topAnchor.constraint(equalTo: self.socialLoginButton.bottomAnchor, constant: 10).isActive = true
        self.bottomButtonsView.widthAnchor.constraint(equalTo: self.emailTextField.widthAnchor).isActive = true
        self.bottomButtonsView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.bottomButtonsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.bottomButtonsView.addSubview(self.switchLoginRegisterButton)
        
        self.switchLoginRegisterButton.centerXAnchor.constraint(equalTo: self.bottomButtonsView.centerXAnchor).isActive = true
        self.switchLoginRegisterButton.widthAnchor.constraint(equalTo: self.bottomButtonsView.widthAnchor).isActive = true
        self.switchLoginRegisterButton.heightAnchor.constraint(equalTo: self.bottomButtonsView.heightAnchor).isActive = true
        self.switchLoginRegisterButton.centerYAnchor.constraint(equalTo: self.bottomButtonsView.centerYAnchor).isActive = true
        self.switchLoginRegisterButton.contentHorizontalAlignment = .center
        
        self.agreeTextView.isHidden = true
    }
    
    //MARK: - Sign In Specific Layouts
    
    func layoutSignInView() {
        self.view.removeConstraints(self.view.constraints)
        self.bottomButtonsView.removeConstraints(self.bottomButtonsView.constraints)
        self.layoutBackgroundImageView()
        self.removeRegisterSpecificViews()
        self.updateSubviewsForStateChange()
        self.constraintSignInView()
        self.constrainSpinner()
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    fileprivate func constraintSignInView() {
        
        let widthForViews = self.view.frame.width * 0.71
        
        self.passwordTextField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.passwordTextField.widthAnchor.constraint(equalTo: self.emailTextField.widthAnchor).isActive = true
        self.passwordTextField.heightAnchor.constraint(equalToConstant: LoginRegisterVC.textFieldHeights).isActive = true
        self.passwordTextField.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -35).isActive = true
        
        self.emailTextField.bottomAnchor.constraint(equalTo: self.passwordTextField.topAnchor, constant: -15).isActive = true
        self.emailTextField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        self.emailTextField.widthAnchor.constraint(equalToConstant: widthForViews).isActive = true
        self.emailTextField.heightAnchor.constraint(equalToConstant: LoginRegisterVC.textFieldHeights).isActive = true
        
        self.logoImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.logoImageView.widthAnchor.constraint(equalToConstant: LoginRegisterVC.imageWidth + 10).isActive = true
        self.logoImageView.heightAnchor.constraint(equalToConstant: LoginRegisterVC.imageWidth  + 40).isActive = true
        self.logoImageView.bottomAnchor.constraint(equalTo: self.emailTextField.topAnchor, constant: -30).isActive = true
        
        var heightRemaining = self.view.frame.height / 2 - LoginRegisterVC.textFieldHeights / 2 - 5
        heightRemaining = heightRemaining - LoginRegisterVC.textFieldHeights - 20
        
        self.signupLoginButton.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant: 28).isActive = true
        self.signupLoginButton.widthAnchor.constraint(equalTo: self.emailTextField.widthAnchor).isActive = true
        self.signupLoginButton.heightAnchor.constraint(equalToConstant: LoginRegisterVC.buttonHeights).isActive = true
        self.signupLoginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.orLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.orLabel.topAnchor.constraint(equalTo: signupLoginButton.bottomAnchor, constant: 13).isActive = true
        self.orLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.orLabel.heightAnchor.constraint(equalToConstant: heightRemaining * 0.1).isActive = true
        
        self.socialLoginButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 13).isActive = true
        self.socialLoginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.socialLoginButton.heightAnchor.constraint(equalTo: self.signupLoginButton.heightAnchor).isActive = true
        self.socialLoginButton.widthAnchor.constraint(equalTo: self.emailTextField.widthAnchor).isActive = true
        
        self.bottomButtonsView.topAnchor.constraint(equalTo: self.socialLoginButton.bottomAnchor, constant: 20).isActive = true
        self.bottomButtonsView.widthAnchor.constraint(equalTo: self.emailTextField.widthAnchor).isActive = true
        self.bottomButtonsView.heightAnchor.constraint(equalToConstant: heightRemaining * 0.12).isActive = true
        self.bottomButtonsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        self.divider.text = "|"
        self.divider.textAlignment = .center
        self.bottomButtonsView.addSubview(self.divider)
        self.divider.textColor = StyleGuideManager.loginPageTextColor
        
        self.divider.centerXAnchor.constraint(equalTo: self.bottomButtonsView.centerXAnchor).isActive = true
        self.divider.heightAnchor.constraint(equalTo: self.bottomButtonsView.heightAnchor).isActive = true
        self.divider.centerYAnchor.constraint(equalTo: self.bottomButtonsView.centerYAnchor).isActive = true
        self.divider.widthAnchor.constraint(equalToConstant: 10).isActive = true

        self.bottomButtonsView.addSubview(forgotPasswordButton)
        
        self.forgotPasswordButton.leftAnchor.constraint(equalTo: self.bottomButtonsView.leftAnchor, constant: 5).isActive = true
        self.forgotPasswordButton.topAnchor.constraint(equalTo: self.bottomButtonsView.topAnchor).isActive = true
        self.forgotPasswordButton.rightAnchor.constraint(equalTo: self.divider.leftAnchor, constant: -15).isActive = true
        self.forgotPasswordButton.bottomAnchor.constraint(equalTo: self.bottomButtonsView.bottomAnchor).isActive = true
        self.forgotPasswordButton.contentHorizontalAlignment = .right
        self.forgotPasswordButton.sizeToFit()

        self.switchLoginRegisterButton.contentHorizontalAlignment = .left

        self.switchLoginRegisterButton.rightAnchor.constraint(equalTo: self.bottomButtonsView.rightAnchor, constant: -5).isActive = true
        self.switchLoginRegisterButton.topAnchor.constraint(equalTo: self.bottomButtonsView.topAnchor).isActive = true
        self.switchLoginRegisterButton.leftAnchor.constraint(equalTo:self.divider.rightAnchor, constant: 20).isActive = true
        self.switchLoginRegisterButton.bottomAnchor.constraint(equalTo: self.bottomButtonsView.bottomAnchor).isActive = true
        
        self.closeButton.constrainWidthAndHeightToValueAndActivate(value: LoginRegisterVC.closeButtonWidthHeight)
        self.closeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.closeButton.topAnchor.constraint(equalTo: self.bottomButtonsView.bottomAnchor, constant: 10).isActive = true
        
        setupTextViews()
        
        self.agreeTextView.isHidden = false
    }
    
    private func setupTextViews() {
        
        view.addSubview(agreeTextView)
        agreeTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        agreeTextView.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.8).isActive = true
        
        let height = estimateFrameForText(text: AgreeText).height + 22
        
        agreeTextView.heightAnchor.constraint(equalToConstant: height).isActive = true
        agreeTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: DEVICE_WIDTH * 0.8, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    func addSpinner() {
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.view.addSubview(self.spinner!)
        self.view.isUserInteractionEnabled = false
        self.constrainSpinner()
        self.spinner!.startAnimating()
        self.spinner!.hidesWhenStopped = true
    }
    
    func stopSpinner() {
        if self.spinner != nil {
            self.spinner!.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.spinner!.removeFromSuperview()
            self.spinner = nil
        }

    }
    
    fileprivate func constrainSpinner() {
        if self.spinner != nil {
            self.view.bringSubview(toFront: self.spinner!)
            self.spinner!.translatesAutoresizingMaskIntoConstraints = false
            self.spinner!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            self.spinner!.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            self.spinner!.widthAnchor.constraint(equalToConstant: 60).isActive = true
            self.spinner!.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
    }
    
    fileprivate func registerImageTopPadding () -> CGFloat {
        return self.view.frame.height / 10
    }
    
    fileprivate func sidePadding() -> CGFloat {
        return self.view.frame.width * 0.06
    }
    
}

extension LoginRegisterVC: ToplessTextFieldDelegate {
    func setTextFieldDelegates() {
        let textFields = [self.emailTextField, self.fullNameTextField, self.passwordTextField, self.confirmPasswordTextField]
        for tf in textFields {
            tf.toplessTextfieldDelegate = self
        }
    }
    
    func didDismissKeyboard(textField: ToplessTextField) {
        if textField == self.emailTextField {
            if self.state == .login {
                self.passwordTextField.becomeFirstResponder()
            } else if self.state == .register {
                self.fullNameTextField.becomeFirstResponder()
            }
        }
        
        if textField == self.passwordTextField && self.state == .register {
            self.confirmPasswordTextField.becomeFirstResponder()
        }
        
        if textField == self.fullNameTextField && self.state == .register {
            self.passwordTextField.becomeFirstResponder()
        }
    }
    
    func toplessTextFieldDidEndEdting() {
    }
    
    func toplessTextFieldDidBeginEditing() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func handleTap(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.view.removeGestureRecognizer(gesture)
    }
}
