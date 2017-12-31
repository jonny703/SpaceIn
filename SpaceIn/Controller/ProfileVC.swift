
//
//  ProfileVC.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import Firebase
import OneSignal


class ProfileVC: UIViewController {
    
    //MARK: - UI
    fileprivate let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    fileprivate let containerView = UIView(asConstrainable: true, frame: CGRect.zero)
    fileprivate let imageContainerView = UIView(frame: CGRect.zero)
    fileprivate let imageView = UIImageView(frame: CGRect.zero)
    fileprivate let nameLabel = UILabel(asConstrainable: true, frame: CGRect.zero)
    fileprivate let ageLabel = UILabel(asConstrainable: true, frame: CGRect.zero)
    fileprivate let jobIconImageView = UIImageView(frame: CGRect.zero)
    fileprivate let bioView = UITextView(frame: CGRect.zero)
    fileprivate let startConvoLogOutButton = RoundedButton(filledIn: true, color: StyleGuideManager.floatingSpaceinLabelColor)
    
    fileprivate let notifciationsLabel = UILabel(asConstrainable: true, frame: CGRect.zero)
    
    
    fileprivate let locationIcon = UIImageView(image: UIImage(named: AssetName.profileLocation.rawValue), asConstrainable: true)
    fileprivate let locationLabel = UILabel(asConstrainable: true, frame: CGRect.zero)
    
    fileprivate let jobIcon = UIImageView(image: UIImage(named: AssetName.jobIcon.rawValue), asConstrainable: true)
    fileprivate let jobLabel = UILabel(asConstrainable: true, frame: CGRect.zero)
    
    fileprivate let toggle = UISwitch(frame: CGRect.zero)
    
    fileprivate let spinner = UIActivityIndicatorView()
    
    //Textfields
    fileprivate let nameTextField = UITextField(frame: CGRect.zero)
    fileprivate let ageTextField = UITextField(frame: CGRect.zero)
    fileprivate let locationTextField = UITextField(frame: CGRect.zero)
    fileprivate let jobTextField = UITextField(frame: CGRect.zero)
    
    
    
    //MARK: - Constraints
    fileprivate var containerYConstraint: NSLayoutConstraint?
    fileprivate var buttonHeightConstraint: NSLayoutConstraint?
    fileprivate var switchHeightConstraint: NSLayoutConstraint?
    fileprivate var switchToLabelConstraint: NSLayoutConstraint?
    fileprivate var notificationHeightConstraint: NSLayoutConstraint?
    fileprivate var labelToBottomConstraint: NSLayoutConstraint?
    
    //MARK: - Internet Connection
    var reachability: Reachability? = Reachability()
    
    
    //MARK: - Layout Values
    fileprivate static let containerViewWidthMultiplier: CGFloat = 0.75
    fileprivate static let containerViewheightMultiplier: CGFloat = 0.65
    fileprivate static let closeButtonTopPadding: CGFloat = 0.0
    fileprivate static let closeButtonRightPadding: CGFloat = 30.0
    fileprivate static let closeButtonHeight: CGFloat = 40.0
    fileprivate static let imageViewTopPadding: CGFloat = 70.0
    fileprivate static let imageViewHeight: CGFloat = 78.0
    fileprivate static let nameLabelTopPadding: CGFloat = 5.0
    fileprivate static let nameLabelHeight: CGFloat = 25.0
    fileprivate static let ageLabelTopPadding: CGFloat = 1.0
    fileprivate static let locationLabelBottomPadding: CGFloat = 6.0
    fileprivate static let ageLabelHeight: CGFloat = 25.0
    fileprivate static let locationAndJobViewHeight: CGFloat = 20
    fileprivate static let bioViewHeight: CGFloat = 80
    fileprivate static let defaultButtonHeight: CGFloat = 40
    fileprivate static let switchHeightMultiplier: CGFloat = 0.75
    fileprivate static let notificationLabelHeightMultiplier: CGFloat = 0.5
    fileprivate static let notificationsLabelTopPadding: CGFloat = 5
    fileprivate static let bottomPadding: CGFloat = -50
    fileprivate static let animationDuration: TimeInterval = 0.5
    fileprivate static let doneButtonHeight: CGFloat = 44
    fileprivate static let animateKeyboardDuration:TimeInterval = 0.3
    
    //MARK: - Copy
    fileprivate let defaultText = "Not Provided"
    fileprivate let nonExpandedPrefixText = "Tap Settings to add your "
    fileprivate let expandedPrefixText = "Tap to add your "
    
    
    //MARK: - Properties
    fileprivate var userForProfile: SpaceInUser?
    fileprivate var isUserProfile = true
    fileprivate var isExpanded = false {
        didSet {
            listenForNotifications(isExpanded)
            
            if !isExpanded {
                endEditing()
            }
        }
    }
    
    fileprivate var doneButton: UIButton?
    fileprivate var viewAppeared = false
    fileprivate var editingView: UIView? = nil
    fileprivate var hiddenView: UIView? = nil
    fileprivate var bioViewTextIsValid = false // need this var to determine if the bioviewtext should be edited programatically
    fileprivate var didMakeEdits = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        addBlurEffectViewFrame()
        
//        setupBlurBackground()
        setup()
    }
    
    func setupBlurBackground() {
        let blurView = UIView()
        blurView.frame = self.view.frame
        
        view.addSubview(blurView)
        blurView.backgroundColor = .white
        blurView.alpha = 0.9
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewAppeared = true
    }
    
    deinit {
        removeNotifications()
    }
    
    public convenience init(user: SpaceInUser, isCurrentUser: Bool) {
        self.init()
        userForProfile = user
        self.isUserProfile = isCurrentUser
    }
}


//MARK: - Setup
extension ProfileVC {
    fileprivate func setup() {
        setupContainerView()
        setupText()
    }
    
    fileprivate func setupBackground() {
        guard viewAppeared == false else { return }
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = UIColor.clear
            
            //always fill the view
            
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(blurEffectView, at: 0)
            blurEffectView.frame = CGRect(x: view.frame.width / 2, y: view.frame.height / 2, width: 0, height: 0)
            
        } else {
            view.backgroundColor = .clear
        }
    }
    
    fileprivate func addBlurEffectViewFrame() {
        guard viewAppeared == false else { return }
        
        self.blurEffectView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = UIColor.white
        
        view.addSubview(containerView)
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerYConstraint = containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        containerYConstraint?.isActive = true
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: ProfileVC.containerViewWidthMultiplier).isActive = true
        //height is inferred by subview heights
        
        containerView.layer.cornerRadius = 8.0
        containerView.clipsToBounds = true
        
        setupCloseButton()
        setupSettingsButton()
        setupProfileImage()
        setupNameLabel()
        setupAgeLabel()
        setupLoatonAndJobView()
        setupBioView()
        setupLogOutStartConversationButton()
        setupToggleView()
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton(asConstrainable: true, frame: CGRect.zero)
        closeButton.setTitle("", for: .normal)
        
        
        let closeButtonImage = UIImage(named: AssetName.dismissButton.rawValue)
        closeButton.setImage(closeButtonImage, for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.contentVerticalAlignment = .fill
        closeButton.contentHorizontalAlignment = .fill
        
        containerView.addSubview(closeButton)
        
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ProfileVC.closeButtonTopPadding).isActive = true
        closeButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -ProfileVC.closeButtonRightPadding).isActive = true
        
        let height: CGFloat = ProfileVC.closeButtonHeight
        closeButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: height * 0.75).isActive = true
        
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
    }
    
    private func setupSettingsButton() {
        guard isUserProfile else {
            print("No need to set up settings button")
            return
        }
        
        let settingsButton = UIButton(asConstrainable: true, frame: CGRect.zero)
        let settingsImage = UIImage(named: AssetName.settingsButton.rawValue)
        settingsButton.setImage(settingsImage, for: .normal)
        settingsButton.imageView?.contentMode = .scaleAspectFit
        
        containerView.addSubview(settingsButton)
        
        let widthHeight: CGFloat = ProfileVC.closeButtonHeight
        let leftSidePadding: CGFloat = ProfileVC.closeButtonRightPadding / 2
        let topPadding: CGFloat = ProfileVC.closeButtonRightPadding / 2
        
        settingsButton.widthAnchor.constraint(equalToConstant: widthHeight).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: widthHeight).isActive = true
        settingsButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: leftSidePadding).isActive = true
        settingsButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: topPadding).isActive = true
        
        settingsButton.addTarget(self, action: #selector(settingsPressed), for: .touchUpInside)
    }
    
    private func setupProfileImage() {
        let isPlaceholderImage = userForProfile?.image == nil
        
        let image = userForProfile?.image ?? UIImage(named: AssetName.profilePlaceholder.rawValue) ?? #imageLiteral(resourceName: "profilePlaceHolder")
        imageView.image = image
        
        // we add a clear view to hold the imageview that way we can keep the height for the contraints. we then add the imageview with a frame based layout
        
        
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageContainerView)
        
        imageContainerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        imageContainerView.widthAnchor.constraint(equalToConstant: ProfileVC.imageViewHeight).isActive = true
        imageContainerView.heightAnchor.constraint(equalToConstant: ProfileVC.imageViewHeight).isActive = true
        imageContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ProfileVC.imageViewTopPadding).isActive = true
        
        imageContainerView.addSubview(imageView)
        
        imageView.frame = CGRect(x: 0, y: 0, width: ProfileVC.imageViewHeight, height: ProfileVC.imageViewHeight)
        
        imageView.contentMode =  isPlaceholderImage ? .scaleAspectFit : .scaleAspectFill // placeholder appears differently if .scaleaspectfill
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedEditableView(gesture:)))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func setupNameLabel() {
        nameLabel.font = StyleGuideManager.sharedInstance.profileNameLabelFont()
        nameLabel.textAlignment = .center
        nameLabel.textColor = .black
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        
        containerView.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: ProfileVC.nameLabelTopPadding).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.9, constant: 0).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: ProfileVC.nameLabelHeight).isActive = true
        
        nameLabel.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedEditableView(gesture:)))
        nameLabel.addGestureRecognizer(gestureRecognizer)
        
        
    }
    
    private func setupAgeLabel() {
        ageLabel.font = StyleGuideManager.sharedInstance.profileSublabelFont()
        ageLabel.textAlignment = .center
        ageLabel.textColor = .lightGray
        ageLabel.adjustsFontSizeToFitWidth = true
        ageLabel.minimumScaleFactor = 0.5
        
        containerView.addSubview(ageLabel)
        
        ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: ProfileVC.ageLabelTopPadding).isActive = true
        ageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        ageLabel.heightAnchor.constraint(equalToConstant: ProfileVC.ageLabelHeight).isActive = true
        ageLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        
        ageLabel.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedEditableView(gesture:)))
        ageLabel.addGestureRecognizer(gestureRecognizer)
    }
    
    private func setupLoatonAndJobView() {
        setupIconWithLabel(icon: locationIcon, label: locationLabel, constrainBelow: ageLabel, amount: ProfileVC.ageLabelTopPadding)
        setupIconWithLabel(icon: jobIcon, label: jobLabel, constrainBelow: locationLabel, amount: ProfileVC.locationLabelBottomPadding)
        
        locationLabel.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedEditableView(gesture:)))
        locationLabel.addGestureRecognizer(gestureRecognizer)
        
        jobLabel.isUserInteractionEnabled = true
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(tappedEditableView(gesture:)))
        jobLabel.addGestureRecognizer(gestureRecognizer2)
        
    }
    
    private func setupIconWithLabel(icon: UIImageView, label: UILabel, constrainBelow: UIView, amount: CGFloat) {
        containerView.addSubview(label)
        containerView.addSubview(icon)
        
        
        label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: constrainBelow.bottomAnchor, constant: amount).isActive = true
        label.heightAnchor.constraint(equalToConstant: ProfileVC.locationAndJobViewHeight).isActive = true
        label.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.45).isActive = true
        
        icon.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: ProfileVC.locationAndJobViewHeight).isActive = true
        icon.heightAnchor.constraint(equalToConstant: ProfileVC.locationAndJobViewHeight).isActive = true
        icon.rightAnchor.constraint(equalTo: label.leftAnchor, constant: -5).isActive = true
        
        icon.contentMode = .scaleAspectFit
        
        label.textAlignment = .center
        label.font = StyleGuideManager.sharedInstance.profileSublabelFont()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textColor = .lightGray
    }
    
    private func setupBioView() {
        let profileHasValidBio = (userForProfile?.bio?.characters.count ?? 0) > 0
        
        if profileHasValidBio {
            bioView.text = userForProfile?.bio
            bioViewTextIsValid = true
        } else {
            bioView.text = defaultTextForState(with: "Bio")
        }
        
        bioView.delegate = self
        bioView.isEditable = false
        bioView.font = StyleGuideManager.sharedInstance.profileBioFont()
        
        bioView.textColor = .lightGray
        bioView.textAlignment = .center
        
        bioView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bioView)
        
        bioView.topAnchor.constraint(equalTo: jobLabel.topAnchor, constant: 40).isActive = true
        bioView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        bioView.heightAnchor.constraint(equalToConstant: ProfileVC.bioViewHeight).isActive = true
        bioView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85).isActive = true
        
        bioView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedEditableView(gesture:)))
        bioView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    private func setupLogOutStartConversationButton() {
        startConvoLogOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonTitle = isUserProfile ? "Log Out" : "Start Conversation"
        startConvoLogOutButton.setTitle(buttonTitle, for: .normal)
        
        containerView.addSubview(startConvoLogOutButton)
        startConvoLogOutButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        startConvoLogOutButton.topAnchor.constraint(equalTo: bioView.bottomAnchor, constant: 20).isActive = true
        
        var height: CGFloat = ProfileVC.defaultButtonHeight
        
        if isUserProfile && isExpanded == false {
            height = 0
            startConvoLogOutButton.alpha = 0.0
        }
        
        buttonHeightConstraint = startConvoLogOutButton.heightAnchor.constraint(equalToConstant: height)
        
        buttonHeightConstraint?.isActive = true
        startConvoLogOutButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85).isActive = true
        
        startConvoLogOutButton.addTarget(self, action: #selector(self.startConversationOrLogOut), for: .touchUpInside)
        
    }
    
    private func setupToggleView() {
        containerView.addSubview(toggle)
        
        toggle.translatesAutoresizingMaskIntoConstraints = false
        
        toggle.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        toggle.topAnchor.constraint(equalTo: startConvoLogOutButton.bottomAnchor, constant: 20).isActive = true
        toggle.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        setSwitchHeightConstraint(forExpandedState: isExpanded)
        toggle.alpha = 0.0
        
        toggle.onTintColor = StyleGuideManager.floatingSpaceinLabelColor
//        toggle.isOn = toggleShouldBeOn()
        
        containerView.addSubview(notifciationsLabel)
        notifciationsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var topPaddingForLabel = isUserProfile ? ProfileVC.notificationsLabelTopPadding : 0
        
        if isUserProfile && !isExpanded {
            topPaddingForLabel = 0
        }
        
        switchToLabelConstraint = notifciationsLabel.topAnchor.constraint(equalTo: toggle.bottomAnchor, constant: topPaddingForLabel)
        switchToLabelConstraint?.isActive = true
        
        notifciationsLabel.centerXAnchor.constraint(equalTo: toggle.centerXAnchor).isActive = true
        
        setNotificationLabelHeightConstraint(forExapndedState: isExpanded)
        
        notifciationsLabel.widthAnchor.constraint(equalTo: startConvoLogOutButton.widthAnchor, constant: 0.45).isActive = true
        
        labelToBottomConstraint =  notifciationsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: ProfileVC.bottomPadding)
        
        labelToBottomConstraint?.isActive = true
        
        notifciationsLabel.textAlignment = .center
        notifciationsLabel.alpha = 0.0
        
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let isSubscribed = status.subscriptionStatus.subscribed
        
        toggle.setOn(isSubscribed, animated: true)
        setNotificationsText(on: toggle.isOn)
        
        toggle.addTarget(self, action: #selector(handleToggleForPush(sender:)), for: .valueChanged)
    }
    
    func handleToggleForPush(sender: UISwitch) {
        setNotificationsText(on: sender.isOn)
        if !sender.isOn {
            OneSignal.setSubscription(false)
        } else {
            OneSignal.setSubscription(true)
        }
    }
}


//MARK: - Button targets
extension ProfileVC {
    @objc fileprivate func closePressed() {
        savedAndClose()
    }
}


//MARK: - Save and Close

extension ProfileVC {
    fileprivate func savedAndClose() {
        endEditing()
        
        guard isUserProfile else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        guard ReachabilityManager.shared.internetIsUp else {
            presentProfileEditError(isServerIssue: false)
            return
        }
        
        setToState(on: false)
        updateSpaceinUserIfNeccessary { (success, returnType) in
            print("update done")
            DispatchQueue.main.async { [weak self] in
                if success {
                    self?.dismiss(animated: true, completion: nil)
                } else if let returnType = returnType {
                    self?.setToState(on: true)
                    self?.handleFirebaseReturnTypeForProfileEdit(returnType: returnType)
                } else {
                    print("WARNING: This should not be possible. there isn't a return type and success is false")
                    //we just dismiss because this shouldn't be possible
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}


//MARK: - Settings

extension ProfileVC {
    @objc fileprivate func settingsPressed() {
        guard isUserProfile else { return }
        
        let isExpanding = !isExpanded
        
        buttonHeightConstraint?.constant = isExpanding ? ProfileVC.defaultButtonHeight : 0
        switchToLabelConstraint?.constant = isExpanding ? ProfileVC.notificationsLabelTopPadding : 0
        
        setNotificationLabelHeightConstraint(forExapndedState: isExpanding)
        setSwitchHeightConstraint(forExpandedState: isExpanding)
        
        UIView.animate(withDuration: ProfileVC.animationDuration) {
            self.view.layoutIfNeeded()
            self.toggle.alpha = isExpanding ? 1.0 : 0.0
            self.notifciationsLabel.alpha = isExpanding ? 1.0 : 0.0
            self.startConvoLogOutButton.alpha = isExpanding ? 1.0 : 0.0
        }
        
        isExpanded = isExpanding
        setupText()
    }
    
    fileprivate func setNotificationLabelHeightConstraint(forExapndedState: Bool) {
        if notificationHeightConstraint != nil {
            notifciationsLabel.removeConstraint(notificationHeightConstraint!)
            notificationHeightConstraint = nil
        }
        
        var notificationLabelHeightMultiplier = ProfileVC.notificationLabelHeightMultiplier
        
        if !isUserProfile || !forExapndedState {
            notificationLabelHeightMultiplier = 0
        }
        
        notificationHeightConstraint = notifciationsLabel.heightAnchor.constraint(equalTo: toggle.heightAnchor, multiplier: notificationLabelHeightMultiplier)
        notificationHeightConstraint?.isActive = true
    }
    
    fileprivate func setSwitchHeightConstraint(forExpandedState: Bool) {
        if switchHeightConstraint != nil {
            toggle.removeConstraint(switchHeightConstraint!)
            switchHeightConstraint = nil
        }
        
        var multiplierForSwitchHeight = CGFloat(0)
        
        if isUserProfile {
            if forExpandedState {
                multiplierForSwitchHeight = ProfileVC.switchHeightMultiplier
            } else {
                multiplierForSwitchHeight = 0
            }
        }
        
        switchHeightConstraint = toggle.heightAnchor.constraint(equalTo: startConvoLogOutButton.heightAnchor, multiplier: multiplierForSwitchHeight)
        switchHeightConstraint?.isActive = true
    }
}

//MARK: - Notification

extension ProfileVC {
    fileprivate func toggleShouldBeOn() -> Bool {
        return true
    }
    
    fileprivate func setNotificationsText(on: Bool) {
        
        let onOff = on ? "ON" : "OFF"
        
        
        let labelFont = StyleGuideManager.sharedInstance.profileNotificationsFont()
        let attributes = [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: UIColor.lightGray]
        
        let notificationsText = NSString(string: "Notifications: \(onOff)")
        let attributedText = NSMutableAttributedString(string: notificationsText as String, attributes: attributes)
        
        let rangeForDifferentText = notificationsText.range(of: onOff)
        
        attributedText.addAttributes([NSForegroundColorAttributeName: StyleGuideManager.floatingSpaceinLabelColor], range: rangeForDifferentText)
        
        notifciationsLabel.attributedText = attributedText
    }
}



//MARK: - Editing

extension ProfileVC {
    @objc fileprivate func tappedEditableView(gesture: UITapGestureRecognizer) {
        print("tapped")
        
        guard isExpanded == true && isUserProfile == true else {
            print("failed 1")
            return
        }
        
        guard let viewForGesture = gesture.view else {
            print("There is no view for the gesture")
            return
        }
        
        editView(view: viewForGesture)
    }
    
    fileprivate func textIsPlaceholderText(text: String) -> Bool {
        return text.contains(expandedPrefixText) || text.contains(nonExpandedPrefixText)
    }
    
    
    private func editView(view: UIView) {
        if view == imageView || view == imageContainerView {
            editImage()
        } else if view == ageLabel{
            editAge()
        } else if view == nameLabel {
            editName()
        } else if view == locationIcon || view == locationLabel {
            editLocation()
        } else if view == jobIcon || view == jobLabel {
            editJob()
        } else if view == bioView {
            editBio()
        }
    }
    
    private func editName() {
        willEdit(label: nameLabel, with: nameTextField)
        
        nameTextField.returnKeyType = .done
        nameTextField.becomeFirstResponder()
    }
    
    private func editAge() {
        willEdit(label: ageLabel, with: ageTextField)
        
        if textIsPlaceholderText(text: ageTextField.text!) {
            ageTextField.text = "18"
        }
        
        ageTextField.keyboardType = .numberPad
        ageTextField.inputAccessoryView = ageDoneButton()
        ageTextField.becomeFirstResponder()
    }
    
    
    
    private func editLocation() {
        willEdit(label: locationLabel, with: locationTextField)
        
        locationTextField.translatesAutoresizingMaskIntoConstraints = false
        locationTextField.centerXAnchor.constraint(equalTo: locationLabel.centerXAnchor).isActive = true
        locationTextField.centerYAnchor.constraint(equalTo: locationLabel.centerYAnchor).isActive = true
        locationTextField.heightAnchor.constraint(equalTo: locationLabel.heightAnchor).isActive = true
        locationTextField.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        
        
        locationIcon.isHidden = true
        locationTextField.returnKeyType = .done
        locationTextField.becomeFirstResponder()
    }
    
    private func editJob() {
        willEdit(label: jobLabel, with: jobTextField)
        
        jobIcon.isHidden = true
        jobTextField.returnKeyType = .done
        jobTextField.becomeFirstResponder()
    }
    
    private func editBio() {
        endEditing()
        
        bioView.isEditable = true
        bioView.isUserInteractionEnabled = true
        bioView.returnKeyType = .done
        
        if !bioViewTextIsValid {
            bioView.text = ""
        }
        
        
        bioView.becomeFirstResponder()
    }
    
    
    private func willEdit(label: UILabel, with textField: UITextField) {
        endEditing() // added here in case we are switching text fields.
        
        textField.frame = label.frame
        textField.textColor = label.textColor
        textField.font = label.font
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = label.textAlignment
        textField.delegate = self
        
        if let textForLabel = label.text {
            if textIsPlaceholderText(text: textForLabel) {
                
            } else {
                textField.text = textForLabel
            }
        }
        
        label.isHidden = true
        editingView = textField
        hiddenView = label
        
        containerView.addSubview(textField)
    }
    
    private func ageDoneButton() -> UIButton {
        let button = UIButton(asConstrainable: false, frame: CGRect.zero)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = StyleGuideManager.sharedInstance.profileNameLabelFont()
        button.titleLabel?.textColor = .white
        button.backgroundColor = StyleGuideManager.floatingSpaceinLabelColor
        
        button.addTarget(self, action: #selector(endEditing), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: ProfileVC.doneButtonHeight)
        
        doneButton = button
        
        return button
    }
}


extension ProfileVC {
    fileprivate func editImage() {
        guard isUserProfile else {
            return
        }
        
        endEditing()
        
        let imageChoices = imageAlertActionOptions()
        
        guard imageChoices.count == 2  else {
            if imageChoices.count == 0 {
                presentNoWayToAccessPhotos()
            } else if MediaManager.shared.cameraPermissionStatus() == .accepted || MediaManager.shared.cameraPermissionStatus() == .notAsked {
                present(cameraVC: true)
            } else {
                present(cameraVC: false)
            }
            
            return
        }
        
        let alertController = UIAlertController(title: "How would you like to choose your profile picture?", message: nil, preferredStyle: .actionSheet)
        
        
        for action in imageChoices {
            alertController.addAction(action)
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func imageAlertActionOptions() -> [UIAlertAction] {
        var options = [UIAlertAction]()
        
        let cameraStatus = MediaManager.shared.cameraPermissionStatus()
        
        switch cameraStatus {
        case .accepted, .notAsked:
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                self.present(cameraVC: true)
            }
            
            options.append(cameraAction)
        default:
            break
        }
        
        let cameraRollStatus = MediaManager.shared.cameraRollPermissionStatus()
        
        switch cameraRollStatus {
        case .notDetermined, .authorized:
            let cameraRollAction = UIAlertAction(title: "Camera Roll", style: .default) { (action) in
                self.present(cameraVC: false)
            }
            
            options.append(cameraRollAction)
        default:
            break
        }
        
        return options
        
    }
    
    private func present(cameraVC: Bool) {
        let vc = cameraVC ? imagePickerCamera() : imagePickerPhotos()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    private func imagePickerCamera() -> UIImagePickerController {
        let finalPicker = imagePicker()
        finalPicker.sourceType = .camera
        finalPicker.cameraDevice = .front
        
        return finalPicker
    }
    
    
    private func imagePicker() -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .camera
        
        
        imagePicker.delegate = self
        
        return imagePicker
    }
    
    private func imagePickerPhotos() -> UIImagePickerController {
        let picker = imagePicker()
        picker.sourceType = .photoLibrary
        
        return picker
    }
    
    
    private func presentNoWayToAccessPhotos() {
        let alertController = UIAlertController(title: "No Way To Edit Profile Picture", message: "This device has denied permissions to both the camera roll and the camera", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
        }))
        
        present(alertController, animated: true, completion: nil)
    }
}


//MARK: - TextEntry

extension ProfileVC: UITextFieldDelegate, UITextViewDelegate {
    @objc fileprivate func endEditing() {
        view.endEditing(true)
        editingView?.removeFromSuperview()
        editingView = nil
        hiddenView?.isHidden = false
        hiddenView = nil
        doneButton = nil
        
        // the editing field is too wide so we have to hide these when editing
        locationIcon.isHidden = false
        jobIcon.isHidden = false
    }
    
    //Textfield
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        let allowableRange = characterLimitForView(view: textField)
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        let rangeIsOk = newLength <= allowableRange
        
        if textField == ageTextField {
            if newLength == 0 {
                doneButton?.backgroundColor = UIColor.lightGray
                doneButton?.isUserInteractionEnabled = false
            } else {
                doneButton?.backgroundColor = StyleGuideManager.floatingSpaceinLabelColor
                doneButton?.isUserInteractionEnabled = true
            }
        }
        
        return rangeIsOk
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setupText()
    }
    
    
    // TextView
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == bioView && (text == "\n") {
            let _ = textViewShouldEndEditing(textView) // called so the text view dismissal proccess if completed
            return false
        }
        
        let currentCharacterCount = textView.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        let allowableRange = characterLimitForView(view: textView)
        let newLength = currentCharacterCount + text.characters.count - range.length
        
        let shouldChange = newLength <= allowableRange
        
        if shouldChange && textView == bioView && newLength > 0 {
            bioViewTextIsValid = true
        } else if textView == bioView {
            bioViewTextIsValid = false
        }
        
        return shouldChange
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == bioView else { return }
        bioView.isEditable = false
        setupText()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        endEditing()
        return true
    }
    
    private func characterLimitForView(view: UIView) -> Int {
        if view == ageTextField {
            return 2
        } else if view == nameTextField {
            return 30
        } else if view == locationTextField || view == jobTextField {
            return 30
        } else if view == bioView {
            return 140
        } else {
            return 0
        }
    }
}

//MARK: - Notiications

extension ProfileVC {
    fileprivate func listenForNotifications(_ shouldListen: Bool) {
        if shouldListen {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        } else {
            removeNotifications()
        }
        
    }
    
    fileprivate func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let keyboardFrame =  userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        keyboardIsPresentingWithHeight(height: keyboardHeight)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        moveToDefaultHeights()
    }
}


//MARK: - Keyboard handling and animating up and down

extension ProfileVC {
    fileprivate func keyboardIsPresentingWithHeight(height: CGFloat) {
        if bioView.isEditable {
            bioViewWillEditWithKeyboardHeight(height: height)
        } else {
            moveToDefaultHeights()
        }
    }
    
    fileprivate func moveToDefaultHeights() {
        guard containerYConstraint?.constant != 0 else {
            return // it is already down
        }
        
        containerYConstraint?.constant = 0
        
        UIView.animate(withDuration: ProfileVC.animateKeyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func bioViewWillEditWithKeyboardHeight(height: CGFloat) {
        guard containerYConstraint?.constant == 0 else {
            return // it is already up
        }
        
        guard height < bioView.frame.maxY + 10 else {
            return // no need to go up there is space
        }
        
        containerYConstraint?.constant = -20
        
        UIView.animate(withDuration: ProfileVC.animateKeyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
}


//MARK: - Text setup

extension ProfileVC {
    fileprivate func setupText() {
        guard let profile = userForProfile else {
            print("there is no user!!!")
            return
        }
        
        nameLabel.text =  textFieldStringForView(view: nameLabel) ?? (profile.name.characters.count > 0 ? profile.name : defaultTextForState(with: "Name"))
        
        ageLabel.text = textFieldStringForView(view: ageLabel) ?? (profile.age != nil ? String(profile.age!) : defaultTextForState(with: "Age"))
        
        jobLabel.text = textFieldStringForView(view: jobLabel) ?? ((profile.job?.characters.count ?? 0) > 0 ? profile.job! : defaultTextForState(with: "Job"))
        locationLabel.text = textFieldStringForView(view: locationLabel) ?? (profile.location?.characters.count ?? 0 > 0 ? profile.location! : defaultTextForState(with: "Location"))
        
        if !bioViewTextIsValid {
            bioView.text = defaultTextForState(with: "Bio")
        }
    }
    
    private func textFieldStringForView(view: UIView) -> String? {
        if view == nameLabel {
            return nameTextField.text?.validString()
        } else if view == ageLabel {
            return ageTextField.text?.validString()
        } else if view == locationLabel {
            return locationTextField.text?.validString()
        } else if view == jobLabel {
            return jobTextField.text?.validString()
        } else {
            return nil
        }
    }
    
    
    fileprivate func defaultTextForState(with labelName: String) -> String {
        if !isUserProfile {
            return labelName + " " + defaultText
        } else if !isExpanded {
            return nonExpandedPrefixText + labelName
        } else {
            // we are expanded and we are the user profile
            return "Tap to add your \(labelName)"
        }
    }
}


//MARK: - Image Picker

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            imageView.contentMode = .scaleAspectFill
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


//MARK: - Edit Profile

extension ProfileVC {
    fileprivate func updateSpaceinUserIfNeccessary(completion: @escaping(Bool, FirebaseReturnType?) -> ()){
        guard isUserProfile else {
            completion(true, nil)
            return
        }
        
        var profileChanges = ProfileChanges()
        
        if let nameLabelText = nameLabel.text {
            if nameLabelText != userForProfile?.name && !textIsPlaceholderText(text: nameLabelText) && nameLabelText.isValidString() {
                profileChanges.name = nameLabelText
            }
        }
        
        if let age = Int(ageLabel.text ?? "") {
            if age != userForProfile?.age && age > 0 {
                profileChanges.age = age
            }
        }
        
        if let location = locationLabel.text {
            if location != userForProfile?.location && !textIsPlaceholderText(text: location) && location.isValidString() {
                profileChanges.location = location
            }
        }
        
        if let job = jobLabel.text {
            if job != userForProfile?.job && !textIsPlaceholderText(text: job) && job.isValidString() {
                profileChanges.job = job
            }
        }
        
        if userForProfile?.bio != bioView.text && !textIsPlaceholderText(text: bioView.text) && bioView.text.isValidString() {
            profileChanges.bio = bioView.text
        }
        
        if imageView.image != userForProfile?.image {
            profileChanges.image = imageView.image?.resized(toWidth: 100)
        }
        
        guard !profileChanges.isEmpty() else {
            completion(true, nil)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.userForProfile?.madeChanges(changes: profileChanges, completion: { (success, returnType) in
                print("completion is back")
                if !success {
                    completion(false, returnType)
                } else {
                    completion(true, nil)
                }
            })
        }
    }
}


//MARK: - Error Handling

extension ProfileVC {
    fileprivate func handleFirebaseReturnTypeForProfileEdit(returnType: FirebaseReturnType) {
        guard returnType != .Success else {
            print("This should not be called if the return type is success")
            return
        }
        
        switch returnType {
        case .Unknown, .NetworkError:
            presentProfileEditError(isServerIssue: false)
        break // something went wront. try again
        case .TooManyRequests:
            presentProfileEditError(isServerIssue: true)
        break // server is busy. try again
        default:
            presentProfileEditError(isServerIssue: false)
            break
        }
        
        //        //Default
        //
        //        case InvalidToken
        //
        //        //Network
        //        case TooManyRequests
    }
    
    fileprivate func presentProfileEditError(isServerIssue: Bool) {
        let alertMessage = isServerIssue ? AlertMessage.serverIssueSavingProfile() : AlertMessage.networkIssueSavingProfile()
        
        let alertController = UIAlertController(title: alertMessage.alertTitle, message: alertMessage.alertSubtitle ?? nil, preferredStyle: .alert)
        
        
        let tryAgainLaterAction = UIAlertAction(title: alertMessage.actionButton1Title, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(tryAgainLaterAction)
        
        let tryAgainAction = UIAlertAction(title: alertMessage.actionButton2title ?? "Try Again", style: .default) { (action) in
            self.savedAndClose()
        }
        
        alertController.addAction(tryAgainAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}


//MARK: - Loading State
extension ProfileVC {
    fileprivate func setToState(on: Bool) {
        setSpinner(on: !on)
        view.isUserInteractionEnabled = on
    }
    
    private func setSpinner(on: Bool) {
        guard (spinner.superview == nil) == on else {
            // spinner is already at the state we want
            return
        }
        
        if on {
            spinner.frame = CGRect(x: (view.frame.width / 2) - 10, y: (view.frame.height / 2) - 10, width: 20, height: 20)
            spinner.color = UIColor.gray
            view.addSubview(spinner)
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
        
    }
}


//MARK: - Log Out/Start Convo
extension ProfileVC {
    @objc fileprivate func startConversationOrLogOut() {
        if isUserProfile {
            logOut()
        } else {
            startConversation()
        }
    }
    
    private func logOut() {
        FirebaseHelper.signOut()
        if !FirebaseHelper.userIsSignedIn() {
            SpaceInUser.logOut()
            
            
            
            
            NotificationCenter.default.post(name: .FetchUsersWhenLogOut, object: nil)
            
            self.dismiss(animated: true, completion: nil)
        } else {
            presentSignOutFailure()
        }
        
    }
    
    private func presentSignOutFailure() {
        
        let alertMessage = AlertMessage.issueLoggingOut()
        let alertController = UIAlertController(title: alertMessage.alertTitle, message: alertMessage.alertSubtitle ?? nil, preferredStyle: .alert)
        
        
        let yesAction = UIAlertAction(title: alertMessage.actionButton1Title, style: .default) { (action) in
            self.logOut()
        }
        
        alertController.addAction(yesAction)
        
        let noAction = UIAlertAction(title: alertMessage.actionButton2title ?? "No", style: .default) { (action) in
        }
        
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func startConversation() {
        
    }
}



