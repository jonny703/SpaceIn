//
//  InvitationController.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import Firebase
import OneSignal

class InvitationController: UIViewController {
    
    var mapViewController: MapViewController?
    
    var push: Push?
    
    var chatUser: SpaceUser? {
        didSet {
            fetchData()
        }
        
    }
    
    
    fileprivate var viewAppeared = false
    
    //MARK set backgroud Ui when postImageView shows
    
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    var spinner : UIActivityIndicatorView?
    
    //MARK set UI
    
    fileprivate let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    
    let backButton: UIButton = {
        
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.dismissX.rawValue)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        button.tintColor = .white
        return button
        
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Caesar703"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let statusImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.statusIcon.rawValue)?.withRenderingMode(.alwaysTemplate)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .lightGray
        return imageView
        
    }()
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.profilePlaceholder.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
        
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "0.5 km"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "30"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let jobLabel: UILabel = {
        let label = UILabel()
        label.text = "Manager"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let requestLabel: UILabel = {
        let label = UILabel()
        label.text = "Wants to start a conversation with you"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Decline", for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .white
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleDecline), for: .touchUpInside)
        return button
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Accept", for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .white
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupViews()
        self.addSwipeGesture()
    }

}

//MARK: fectch chat user profile
extension InvitationController {
    fileprivate func fetchData() {
        
        if let name = chatUser?.name {
            self.nameLabel.text = name
        }
        if let age = chatUser?.age {
            ageLabel.text = String(describing: age)
        }
        if let job = chatUser?.job {
            jobLabel.text = job
        }
        if let profilePictureStr = chatUser?.profilePictureURL {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profilePictureStr)
        }
        
        if let isLogin = chatUser?.isLogIn {
            
            self.statusImageView.tintColor = isLogin == 1 ? StyleGuideManager.greenColor : .lightGray
        }
    
        
    }
}

//MARK: handle accept and decilne
extension InvitationController {
    
    fileprivate func addSwipeGesture() {
        
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleAccept))
        swipeRightRecognizer.direction = .right
        
        self.view.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleDecline))
        swipeLeftRecognizer.direction = .left
        
        self.view.addGestureRecognizer(swipeLeftRecognizer)
        
    }
    
    
    @objc fileprivate func handleAccept() {
        
        self.handleAcceptAndDeclineWith(actionType: PushAction.accept.rawValue)
    }
    
    @objc fileprivate func handleDecline() {
        
        self.handleAcceptAndDeclineWith(actionType: PushAction.decline.rawValue)
    
    }
    
    private func handleAcceptAndDeclineWith(actionType: String) {
        
        mapViewController?.pushCount -= 1
        mapViewController?.pushLabel.text = String(describing: mapViewController?.pushCount)
        if mapViewController?.pushCount == 0 {
            
            mapViewController?.pushLabel.isHidden = true
        }
        
        self.addSpinner()
        
        var action: String
        var pushKey: Int
        
        if actionType == PushAction.accept.rawValue {
            action = PushAction.accept.rawValue
            pushKey = 1
        } else {
            action = PushAction.decline.rawValue
            pushKey = 2
        }
        
        let ref = Database.database().reference().child("users").child(push!.fromId!)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                if let pushToken = dictionary["pushToken"] as? String {
                    
                    if pushToken != "" {
                        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                        let pushId = status.subscriptionStatus.pushToken
                        
                        if pushId != nil {
                            
                            
                            let pushRef = Database.database().reference().child("push-table").child(self.push!.pushId!)
                            
                            pushRef.removeValue(completionBlock: { (error, pushRef) in
                                
                                if error != nil {
                                    print(error!)
                                    
                                    self.stopSpinner()
                                    self.showErrorAlert(message: "Something went wrong! Try again later")
                                    self.dismissController()
                                    
                                    return
                                }
                                
                                var message: String
                                
                                
                                if actionType == PushAction.accept.rawValue {
                                    message = "Your invitaion was accepted"
                                } else {
                                    message = "Your invitaion was declined"
                                }
                                
                                if let username = SpaceInUser.current?.name {
                                    message = message + " by " + username
                                }
                                
                                let notificationContent = [
                                    "app_id": "65e296d1-6448-4989-b9fc-849eb21b218b",
                                    "include_player_ids": [pushToken],
                                    "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
                                    "ios_badgeType": "Increase",
                                    "ios_badgeCount": 1,
                                    "data": ["fromId": self.push!.toId!, "action": action, "pushId": self.push!.pushId!]
                                    ] as [String : Any]
                                
                                OneSignal.postNotification(notificationContent)
                                
                                if actionType == PushAction.accept.rawValue {
                                    
                                    self.handleAcceptWithFirebasedatabase()
                                } else {
                                    self.stopSpinner()
                                    self.dismissController()
                                }

                                
                            })
                            
//                            let values = ["pushKey": pushKey] as [String: AnyObject]
//                            pushRef.updateChildValues(values) { (error, pushRef) in
//                                
//                                if error != nil {
//                                    print(error!)
//                                    
//                                    self.stopSpinner()
//                                    self.showErrorAlert(message: "Something went wrong! Try again later")
//                                    self.dismissController()
//                                    
//                                    return
//                                }
//                                
//                                var message: String
//                                
//                                
//                                if actionType == PushAction.accept.rawValue {
//                                    message = "Your invitaion was accepted"
//                                } else {
//                                    message = "Your invitaion was declined"
//                                }
//                                
//                                if let username = SpaceInUser.current?.name {
//                                    message = message + " by " + username
//                                }
//                                
//                                let notificationContent = [
//                                    "include_player_ids": [pushToken],
//                                    "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
//                                    "headings": ["en": "Spacein Notification"],
//                                    "subtitle": ["en": "Request"],
//                                    
//                                    "ios_badgeType": "Increase",
//                                    "ios_badgeCount": 1,
//                                    "data": ["fromId": self.push!.toId!, "action": action, "pushId": self.push!.pushId!]
//                                    ] as [String : Any]
//                                
//                                OneSignal.postNotification(notificationContent)
//                                
//                                if actionType == PushAction.accept.rawValue {
//                                    
//                                    self.handleAcceptWithFirebasedatabase()
//                                } else {
//                                    self.stopSpinner()
//                                    self.dismissController()
//                                }
//                                
//                                
//                            }
                        }
                        
                    }
                    
                }
            }
        }, withCancel: nil)

        
    }
    
    private func handleAcceptWithFirebasedatabase() {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = self.push?.toId
        
        let fromId = self.push?.fromId
        
        let timestamp = self.push?.timestamp
        
        let values = ["toId": toId!, "fromId": fromId!, "timestamp": timestamp!, "text": "Hello! I want to chat with you"] as [String : AnyObject]
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error!)
                
                self.stopSpinner()
                self.showErrorAlert(message: "Something went wrong! Try again later")
                self.dismissController()
                
                return
            }
            
            let lastSeenTimeStamp = NSDate().timeIntervalSince1970 as NSNumber
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId!).child(toId!)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1, "lastSeenTimeStamp": lastSeenTimeStamp])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId!).child(fromId!)
            recipientUserMessagesRef.updateChildValues([messageId: 1, "lastSeenTimeStamp": lastSeenTimeStamp])
            
            self.stopSpinner()
            
            self.dismiss(animated: false, completion: {
                
                if let currentController = currentViewController() {
                    
                    
                    currentController.showErrorAlertWithOKCancel("You just accepted one invitaion", message: "Do you want to chat now?", action: { (action) in
                        
                        let chatOnebyOneController = ChatOnebyOneController()
                        chatOnebyOneController.chatUser = self.chatUser
                        chatOnebyOneController.modalPresentationStyle = .overCurrentContext
                        chatOnebyOneController.modalTransitionStyle = .crossDissolve
                        currentController.present(chatOnebyOneController, animated: false, completion: nil)
                    }, completion: nil)
                }
                
            })
        }

    }
}

//MARK: handle dismiss controller

extension InvitationController {
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: setup Background

extension InvitationController {
    
    fileprivate func setupBackground() {
        setupBackgroundView()
        addBlurEffectViewFrame()
    }
    
    fileprivate func setupBackgroundView() {
        guard viewAppeared == false else { return }
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = UIColor.clear
            
            //always fill the view
            
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(blurEffectView, at: 0)
            blurEffectView.frame = CGRect(x: view.frame.width / 2, y: view.frame.height / 2, width: 0, height: 0)
            self.modalPresentationCapturesStatusBarAppearance = false
        } else {
            view.backgroundColor = .clear
        }
    }
    
    fileprivate func addBlurEffectViewFrame() {
        guard viewAppeared == false else { return }
        
        self.blurEffectView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
    }
}

//MARK: handle spinner

extension InvitationController {
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
    
}

//MARK: setup Views

extension InvitationController {
    
    fileprivate func setupViews() {
        setupBackButton()
        setupProfileViews()
        setupButtons()
    }
    
    private func setupButtons() {
        view.addSubview(declineButton)
        view.addSubview(acceptButton)
        
        declineButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        declineButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        declineButton.topAnchor.constraint(equalTo: requestLabel.bottomAnchor, constant: 30).isActive = true
        declineButton.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -10).isActive = true
        
        acceptButton.widthAnchor.constraint(equalTo: declineButton.widthAnchor).isActive = true
        acceptButton.heightAnchor.constraint(equalTo: declineButton.heightAnchor).isActive = true
        acceptButton.topAnchor.constraint(equalTo: declineButton.topAnchor).isActive = true
        acceptButton.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 10).isActive = true
    }
    
    fileprivate func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }
    
    private func setupProfileViews() {
        
        view.addSubview(nameLabel)
        view.addSubview(statusImageView)
        view.addSubview(distanceLabel)
        view.addSubview(profileImageView)
        view.addSubview(ageLabel)
        view.addSubview(jobLabel)
        view.addSubview(requestLabel)
        
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        statusImageView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        statusImageView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        statusImageView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor, constant: 0).isActive = true
        statusImageView.rightAnchor.constraint(equalTo: nameLabel.leftAnchor, constant: -5).isActive = true
        
        
        distanceLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0).isActive = true
        distanceLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 5).isActive = true
        distanceLabel.isHidden = true
        
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -30).isActive = true
        
        ageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
        
        jobLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        jobLabel.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 10).isActive = true
        
        requestLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        requestLabel.topAnchor.constraint(equalTo: jobLabel.bottomAnchor, constant: 15).isActive = true
    }
}



























