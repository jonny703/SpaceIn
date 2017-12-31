
//
//  UserProfileController.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import Firebase
import OneSignal

enum UserProfileControllerStatus {
    case mapViewController
    case postReplyController
}

class UserProfileController: UIViewController {
    
    var mapViewController: MapViewController?
    var postReplyController: PostReplyController?
    
    var controllerStauts = UserProfileControllerStatus.mapViewController
    
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
    fileprivate let blockButton = RoundedButton(filledIn: true, color: .lightGray)
    fileprivate let reportButton = RoundedButton(filledIn: true, color: .lightGray)
    
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
    fileprivate let nonExpandedPrefixText = "Not Provided "
    fileprivate let expandedPrefixText = "Not Provided "
    
    
    //MARK: - Properties
    fileprivate var userForProfile: SpaceUser?
    fileprivate var isUserProfile = true
    fileprivate var isExpanded = true {
        didSet {
//            listenForNotifications(isExpanded)
            
            if !isExpanded {
//                endEditing()
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
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupBackground()
        addBlurEffectViewFrame()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewAppeared = true
    }
    
    public convenience init(user: SpaceUser) {
        self.init()
        userForProfile = user
    }
}


//MARK: - Setup
extension UserProfileController {
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
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: UserProfileController.containerViewWidthMultiplier).isActive = true
        //height is inferred by subview heights
        
        containerView.layer.cornerRadius = 8.0
        containerView.clipsToBounds = true
        
        setupCloseButton()
//        setupSettingsButton()
        setupProfileImage()
        setupNameLabel()
        setupAgeLabel()
        setupLoatonAndJobView()
        setupBioView()
        setupLogOutStartConversationButton()
        setupBlockReportButton()
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
        
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UserProfileController.closeButtonTopPadding).isActive = true
        closeButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -UserProfileController.closeButtonRightPadding).isActive = true
        
        let height: CGFloat = UserProfileController.closeButtonHeight
        closeButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: height * 0.75).isActive = true
        
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
    }
    
//    private func setupSettingsButton() {
//        guard isUserProfile else {
//            print("No need to set up settings button")
//            return
//        }
//        
//        let settingsButton = UIButton(asConstrainable: true, frame: CGRect.zero)
//        let settingsImage = UIImage(named: AssetName.settingsButton.rawValue)
//        settingsButton.setImage(settingsImage, for: .normal)
//        settingsButton.imageView?.contentMode = .scaleAspectFit
//        
//        containerView.addSubview(settingsButton)
//        
//        let widthHeight: CGFloat = UserProfileController.closeButtonHeight
//        let leftSidePadding: CGFloat = UserProfileController.closeButtonRightPadding / 2
//        let topPadding: CGFloat = UserProfileController.closeButtonRightPadding / 2
//        
//        settingsButton.widthAnchor.constraint(equalToConstant: widthHeight).isActive = true
//        settingsButton.heightAnchor.constraint(equalToConstant: widthHeight).isActive = true
//        settingsButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: leftSidePadding).isActive = true
//        settingsButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: topPadding).isActive = true
//        
////        settingsButton.addTarget(self, action: #selector(settingsPressed), for: .touchUpInside)
//        settingsButton.isHidden = true
//    }
    
    private func setupProfileImage() {
        
        if let profilePictureStr = userForProfile?.profilePictureURL {
            imageView.loadImageUsingCacheWithUrlString(urlString: profilePictureStr)
        } else {
            imageView.image = UIImage(named: AssetName.profilePlaceholder.rawValue)
        }
        
        
        
        // we add a clear view to hold the imageview that way we can keep the height for the contraints. we then add the imageview with a frame based layout
        
        
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageContainerView)
        
        imageContainerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        imageContainerView.widthAnchor.constraint(equalToConstant: UserProfileController.imageViewHeight).isActive = true
        imageContainerView.heightAnchor.constraint(equalToConstant: UserProfileController.imageViewHeight).isActive = true
        imageContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UserProfileController.imageViewTopPadding).isActive = true
        
        imageContainerView.addSubview(imageView)
        
        imageView.frame = CGRect(x: 0, y: 0, width: UserProfileController.imageViewHeight, height: UserProfileController.imageViewHeight)
        
        imageView.contentMode =  .scaleAspectFill // placeholder appears differently if .scaleaspectfill
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        
        
        imageView.isUserInteractionEnabled = false
    }
    
    private func setupNameLabel() {
        nameLabel.font = StyleGuideManager.sharedInstance.profileNameLabelFont()
        nameLabel.textAlignment = .center
        nameLabel.textColor = .black
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        
        containerView.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: UserProfileController.nameLabelTopPadding).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.9, constant: 0).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: UserProfileController.nameLabelHeight).isActive = true
        
        nameLabel.isUserInteractionEnabled = false
    }
    
    private func setupAgeLabel() {
        ageLabel.font = StyleGuideManager.sharedInstance.profileSublabelFont()
        ageLabel.textAlignment = .center
        ageLabel.textColor = .lightGray
        ageLabel.adjustsFontSizeToFitWidth = true
        ageLabel.minimumScaleFactor = 0.5
        
        containerView.addSubview(ageLabel)
        
        ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: UserProfileController.ageLabelTopPadding).isActive = true
        ageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        ageLabel.heightAnchor.constraint(equalToConstant: UserProfileController.ageLabelHeight).isActive = true
        ageLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        
        ageLabel.isUserInteractionEnabled = false
    }
    
    private func setupLoatonAndJobView() {
        setupIconWithLabel(icon: locationIcon, label: locationLabel, constrainBelow: ageLabel, amount: UserProfileController.ageLabelTopPadding)
        setupIconWithLabel(icon: jobIcon, label: jobLabel, constrainBelow: locationLabel, amount: UserProfileController.locationLabelBottomPadding)
        
        locationLabel.isUserInteractionEnabled = false
        
        jobLabel.isUserInteractionEnabled = false
        
    }
    
    private func setupIconWithLabel(icon: UIImageView, label: UILabel, constrainBelow: UIView, amount: CGFloat) {
        containerView.addSubview(label)
        containerView.addSubview(icon)
        
        
        label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: constrainBelow.bottomAnchor, constant: amount).isActive = true
        label.heightAnchor.constraint(equalToConstant: UserProfileController.locationAndJobViewHeight).isActive = true
        label.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.45).isActive = true
        
        icon.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: UserProfileController.locationAndJobViewHeight).isActive = true
        icon.heightAnchor.constraint(equalToConstant: UserProfileController.locationAndJobViewHeight).isActive = true
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
        bioView.isEditable = false
        bioView.font = StyleGuideManager.sharedInstance.profileBioFont()
        
        bioView.textColor = .lightGray
        bioView.textAlignment = .center
        
        bioView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bioView)
        
        bioView.topAnchor.constraint(equalTo: jobLabel.topAnchor, constant: 40).isActive = true
        bioView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        bioView.heightAnchor.constraint(equalToConstant: UserProfileController.bioViewHeight).isActive = true
        bioView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85).isActive = true
        
        bioView.isUserInteractionEnabled = false
        
    }
    
    private func setupLogOutStartConversationButton() {
        startConvoLogOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonTitle = "Start Conversation"
        startConvoLogOutButton.setTitle(buttonTitle, for: .normal)
        
        containerView.addSubview(startConvoLogOutButton)
        startConvoLogOutButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        startConvoLogOutButton.topAnchor.constraint(equalTo: bioView.bottomAnchor, constant: 20).isActive = true
        
        var height: CGFloat = UserProfileController.defaultButtonHeight
        
        if isUserProfile && isExpanded == false {
            height = 0
            startConvoLogOutButton.alpha = 0.0
        }
        
        buttonHeightConstraint = startConvoLogOutButton.heightAnchor.constraint(equalToConstant: height)
        
        buttonHeightConstraint?.isActive = true
        startConvoLogOutButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85).isActive = true
        
        startConvoLogOutButton.addTarget(self, action: #selector(self.startConversationOrLogOut), for: .touchUpInside)
        
    }
    
    private func setupBlockReportButton() {
        
        blockButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        
        blockButton.setTitle("Block this member", for: .normal)
        reportButton.setTitle("Report this member", for: .normal)
        
        containerView.addSubview(blockButton)
        containerView.addSubview(reportButton)
        
        let height: CGFloat = UserProfileController.defaultButtonHeight
        
        blockButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        blockButton.topAnchor.constraint(equalTo: startConvoLogOutButton.bottomAnchor, constant: 10).isActive = true
        blockButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        blockButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85).isActive = true
        
        reportButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
        reportButton.topAnchor.constraint(equalTo: blockButton.bottomAnchor, constant: 10).isActive = true
        reportButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        reportButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85).isActive = true
        
        reportButton.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
        blockButton.addTarget(self, action: #selector(handleBlock), for: .touchUpInside)
    }
    
    func handleReport() {
        
        self.showErrorAlertWithOKCancel("Report this menber", message: "Are you sure to report this member?", action: { (action) in
            self.showErrorAlert(message: "Thank you for taking a moment to report a user on Spacein. It is a great help us to have our own members assist us in keeping the Spacein teams as informative and constructive as possible. We are presently processing your report. Spacein.")
        }, completion: nil)
    }
    
    func handleBlock() {
        self.showErrorAlertWithOKCancel("Block this menber", message: "Are you sure to block this member?", action: { (action) in
            self.showErrorAlert(message: "Thank you for taking a moment to block a user on Spacein. It is a great help us to have our own members assist us in keeping the Spacein teams as informative and constructive as possible. We are presently processing your block. Spacein.")
        }, completion: nil)
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
        toggle.isOn = toggleShouldBeOn()
        
        containerView.addSubview(notifciationsLabel)
        notifciationsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var topPaddingForLabel = isUserProfile ? UserProfileController.notificationsLabelTopPadding : 0
        
        if isUserProfile && !isExpanded {
            topPaddingForLabel = 0
        }
        
        switchToLabelConstraint = notifciationsLabel.topAnchor.constraint(equalTo: toggle.bottomAnchor, constant: topPaddingForLabel)
        switchToLabelConstraint?.isActive = true
        
        notifciationsLabel.centerXAnchor.constraint(equalTo: toggle.centerXAnchor).isActive = true
        
        setNotificationLabelHeightConstraint(forExapndedState: isExpanded)
        
        notifciationsLabel.widthAnchor.constraint(equalTo: startConvoLogOutButton.widthAnchor, constant: 0.45).isActive = true
        
        labelToBottomConstraint =  notifciationsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: UserProfileController.bottomPadding)
        
        labelToBottomConstraint?.isActive = true
        
        notifciationsLabel.textAlignment = .center
        notifciationsLabel.alpha = 0.0
        
        setNotificationsText(on: toggle.isOn)
    }
}


//MARK: - Button targets
extension UserProfileController {
    @objc fileprivate func closePressed() {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - Settings

extension UserProfileController {
    @objc fileprivate func settingsPressed() {
        guard isUserProfile else { return }
        
        let isExpanding = !isExpanded
        
        buttonHeightConstraint?.constant = isExpanding ? UserProfileController.defaultButtonHeight : 0
        switchToLabelConstraint?.constant = isExpanding ? UserProfileController.notificationsLabelTopPadding : 0
        
        setNotificationLabelHeightConstraint(forExapndedState: isExpanding)
        setSwitchHeightConstraint(forExpandedState: isExpanding)
        
        UIView.animate(withDuration: UserProfileController.animationDuration) {
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
        
        var notificationLabelHeightMultiplier = UserProfileController.notificationLabelHeightMultiplier
        
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
                multiplierForSwitchHeight = UserProfileController.switchHeightMultiplier
            } else {
                multiplierForSwitchHeight = 0
            }
        }
        
        switchHeightConstraint = toggle.heightAnchor.constraint(equalTo: startConvoLogOutButton.heightAnchor, multiplier: multiplierForSwitchHeight)
        switchHeightConstraint?.isActive = true
    }
}

//MARK: - Notification

extension UserProfileController {
    fileprivate func toggleShouldBeOn() -> Bool {
        return true
    }
    
    fileprivate func setNotificationsText(on: Bool) {
        let labelFont = StyleGuideManager.sharedInstance.profileNotificationsFont()
        let attributes = [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: UIColor.lightGray]
        
        let notificationsText = NSString(string: "Notifications: ON")
        let attributedText = NSMutableAttributedString(string: notificationsText as String, attributes: attributes)
        
        let rangeForDifferentText = notificationsText.range(of: "ON")
        
        attributedText.addAttributes([NSForegroundColorAttributeName: StyleGuideManager.floatingSpaceinLabelColor], range: rangeForDifferentText)
        
        notifciationsLabel.attributedText = attributedText
    }
}


//MARK: - Keyboard handling and animating up and down

extension UserProfileController {
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
        
        UIView.animate(withDuration: UserProfileController.animateKeyboardDuration) {
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
        
        UIView.animate(withDuration: UserProfileController.animateKeyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
}


//MARK: - Text setup

extension UserProfileController {
    fileprivate func setupText() {
        guard let profile = userForProfile else {
            print("there is no user!!!")
            return
        }
        
        nameLabel.text =  textFieldStringForView(view: nameLabel) ?? ((profile.name?.characters.count)! > 0 ? profile.name : defaultTextForState(with: "Name"))
        
        ageLabel.text = textFieldStringForView(view: ageLabel) ?? (profile.age != nil ? String(describing: profile.age!) : defaultTextForState(with: "Age"))
        
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
            return "Not Provided \(labelName)"
        }
    }
}


//MARK: - Loading State
extension UserProfileController {
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
extension UserProfileController {
    @objc fileprivate func startConversationOrLogOut() {
        startConversation()
    }
    
    private func sendInvitationTo(toId: String, fromId: String) {
        let ref = Database.database().reference().child("users").child(toId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                if let pushToken = dictionary["pushToken"] as? String {
                    
                    if pushToken != "" {
                        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                        let pushId = status.subscriptionStatus.pushToken
                        
                        if pushId != nil {
                            
                            let timestamp = NSDate().timeIntervalSince1970 as NSNumber
                            
                            let values = ["fromId": fromId, "toId": toId, "pushKey": 0, "timestamp": timestamp] as [String: AnyObject]
                            let pushRef = Database.database().reference().child("push-table")
                            let childRef = pushRef.childByAutoId()
                            
                            childRef.updateChildValues(values) { (error, ref) in
                                
                                if error != nil {
                                    print(error!)
                                    return
                                }
                                
                                var message = "I want to chat!"
                                
                                if let username = SpaceInUser.current?.name {
                                    message = username + " wants to chat!"
                                }
                                
                                let notificationContent = [
                                    "app_id": "65e296d1-6448-4989-b9fc-849eb21b218b",
                                    
                                    "include_player_ids": [pushToken],
                                    "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
                                    "headings": ["en": "Chat Invite"],
                                    
                                    "ios_badgeType": "Increase",
                                    "ios_badgeCount": 1,
                                    "data": ["fromId": fromId, "action": "invitation", "pushId": childRef.key]
                                    ] as [String : Any]
                                
                                OneSignal.postNotification(notificationContent)
                                
                                self.mapViewController?.presentInvitationController()
                                
                            }
                        }
                    }
                }
            }
        }, withCancel: nil)

    }
    
    private func startConversation() {
        
        self.dismiss(animated: true) {
            
            if self.controllerStauts == .mapViewController {
                
                guard let fromId = Auth.auth().currentUser?.uid else {
                    return
                }
                
                if let toId = self.userForProfile?.userId {
                    
                    var wasAcceptedInvitaion = false
                    var sentInvitation = 0
                    
                    let userMessageRef = Database.database().reference().child("user-messages").child(fromId)
                    userMessageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if snapshot.hasChild(toId) {
                            wasAcceptedInvitaion = true
                        }
                        
                    }, withCancel: nil)
                    
                    let pushRef = Database.database().reference().child("push-table")
                    
                    pushRef.queryOrdered(byChild: "toId").queryEqual(toValue: toId).observe(.childAdded, with: { (snapshot) in
                        
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            
                            let push = Push(dictionary: dictionary)
                            
                            if push.fromId == fromId {
                                if push.pushKey == 0 {
                                    sentInvitation = 1
                                }
                            }
                        }
                        
                    }, withCancel: nil)
                    
                    pushRef.queryOrdered(byChild: "fromId").queryEqual(toValue: toId).observe(.childAdded, with: { (snapshot) in
                        
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            
                            let push = Push(dictionary: dictionary)
                            
                            if push.toId == fromId {
                                if push.pushKey == 0 {
                                    sentInvitation = 2
                                }
                            }
                        }
                        
                    }, withCancel: nil)
//                    pushRef.queryOrdered(byChild: "fromId").queryEqual(toValue: toId).observe(.childAdded, with: { (snapshot) in
//                        
//                        if let dictionary = snapshot.value as? [String: AnyObject] {
//                            
//                            let push = Push(dictionary: dictionary)
//                            push.pushId = snapshot.key
//                            if push.pushKey == 1 {
//                                
//                                wasAcceptedInvitaion = true
//                            }
//                        }
//                        
//                    }, withCancel: nil)

                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        if wasAcceptedInvitaion == true {
                            self.mapViewController?.presentChatOnebyOneController(user: self.userForProfile!)
                            
                        } else {
                            
                            if sentInvitation == 1 {
                                self.mapViewController?.presentAlreadySentInvitationController()
                            } else if sentInvitation == 0 {
                                self.sendInvitationTo(toId: toId, fromId: fromId)
                            } else {
                                
                                self.mapViewController?.presentAlreadyReceiveInvitaonController()
                                
                            }
                            
                        }
                    })
                }
                
            } else {
                self.postReplyController?.presentChatOnebyOneController(user: self.userForProfile!)
            }
            
        }
        
    }
}



