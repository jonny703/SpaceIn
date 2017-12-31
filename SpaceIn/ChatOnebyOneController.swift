//
//  ChatOnebyOneController.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
import OneSignal

class ChatOnebyOneController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    var chatHistoryController: ChatHistoryController?
    var indexPath: IndexPath?
    
    var chatUser: SpaceUser? {
        didSet {
            fetchData()
        }

    }
    var messages = [Message]()
    
    var startingFrame: CGRect?
    
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    var inputContainerBottomAncher: NSLayoutConstraint?
    var collectionViewBottomAncher: NSLayoutConstraint?
    
    fileprivate var viewAppeared = false
    
    //MARK: - UI
    fileprivate let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    
    let backButton: UIButton = {
        
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.backButton.rawValue)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        button.tintColor = .white
        return button
        
    }()
    
    func dismissController() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = chatUser?.userId else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        
        let lastSeenTimeStamp = NSDate().timeIntervalSince1970 as NSNumber
        userMessagesRef.updateChildValues(["lastSeenTimeStamp": lastSeenTimeStamp] as [String: AnyObject])
        
        dismiss(animated: true) {
            
            if let indexPath = self.indexPath {
                self.chatHistoryController?.reloadTableViewForBadgeAtIndex(indexPath)
                
                let dictionaryData = ["index": indexPath.row] as [String: AnyObject]
                let nc = NotificationCenter.default
                nc.post(name: .ResetBadgeLabel, object: nil, userInfo: dictionaryData)
            }
        }
    }
    
    lazy var collectionView: UICollectionView = {
        var colView: UICollectionView!
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let frame = CGRect(x: DEVICE_WIDTH * 0.1, y: 100, width: DEVICE_WIDTH * 0.8, height: DEVICE_WIDTH * 0.7)
        colView = UICollectionView(frame: frame, collectionViewLayout: layout)
        colView.backgroundColor = UIColor.clear
        colView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        colView.alwaysBounceVertical = true
        colView.showsVerticalScrollIndicator = false
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.dataSource = self
        colView.delegate = self
//        colView.keyboardDismissMode = .interactive
        return colView
    }()
    
    let containerProfileView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.profilePlaceholder.rawValue)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Caesar"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "23 Aug 2017"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var inputContainerView: ChatInputContainerView = {
        
        let chatInputContainerview = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: 40))
        
        chatInputContainerview.chatOnebyOneController = self
        chatInputContainerview.translatesAutoresizingMaskIntoConstraints = false
        return chatInputContainerview
        
    }()
    
    let seperaterView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    
    }()
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        setupKeyboardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBackground()
        addBlurEffectViewFrame()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewAppeared = true
        
        // keyboard show hide remove
//        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func handleKeyboardDidShow() {
        
        if messages.count > 0 {
            
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            
        }
        
    }
    
    let cellId = "cellId"
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        //orientaion enable
        collectionView.collectionViewLayout.invalidateLayout()
    }
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatOnebyOneController = self
        
        let message = messages[indexPath.item]
        
        cell.message = message
        
        cell.textView.text = message.text
        
        if let seconds = message.timestamp?.doubleValue {
            
            let timestampeDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            
            //                timeLabel.text = timestampeDate.description
            cell.timeLabel.text = dateFormatter.string(from: timestampeDate as Date)
            cell.timeLabel.text = returnLeftTimedateformatter(date: seconds)
        }

        
        setupCell(cell: cell, message: message)
        
        
        if let text = message.text {
            cell.bubbleWidthAncher?.constant = 200
            cell.textView.isHidden = false
            
        } else if message.imageUrl != nil {
            
            cell.bubbleWidthAncher?.constant = 200
            cell.textView.isHidden = true
            
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
        
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        
        if message.fromId == Auth.auth().currentUser?.uid {
            
//            if let profileImageUrl = Global.currentUser.profilePictureURL {
//                cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
//            }
            
            
            
            let ref = Database.database().reference().child("users").child(message.fromId!)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    if let profileImageUrl = dictionary["profilePictureURL"] as? String {
                        
                        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
            }, withCancel: nil)

            
            
            cell.bubbleView.backgroundColor = UIColor.white
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.timeLabel.textAlignment = .left
            
            cell.bubbleViewRightAncher?.isActive = true
            cell.bubbleViewLeftAncher?.isActive = false
            cell.profileImageViewRightAncher?.isActive = true
            cell.profileImageViewLeftAncher?.isActive = false
            cell.textViewRightAncher?.constant = -45
            cell.textViewLeftAncher?.constant = 0
        } else {
            
            if let profileImageUrl = self.chatUser?.profilePictureURL {
                cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
            
            cell.bubbleView.backgroundColor = UIColor(r: 0, g: 236, b: 172)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            cell.timeLabel.textAlignment = .right
            
            cell.bubbleViewRightAncher?.isActive = false
            cell.bubbleViewLeftAncher?.isActive = true
            cell.profileImageViewRightAncher?.isActive = false
            cell.profileImageViewLeftAncher?.isActive = true
            cell.textViewRightAncher?.constant = 0
            cell.textViewLeftAncher?.constant = 45
        }
        
        if let messageImageUrl = message.imageUrl {
            
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            
        } else {
            cell.messageImageView.isHidden = true
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
            
            height = estimateFrameForText(text: text).height + 58
            
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            // h1 / w1 = h2 / w2
            //solve for h1
            // h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * 200)
            
            
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
        
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200 - 45, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
}

//MARK: - handleKeyboard
extension ChatOnebyOneController {
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.inputContainerBottomAncher?.constant = 0.0
                self.collectionViewBottomAncher?.constant = -40
            } else {
                self.inputContainerBottomAncher?.constant = -(endFrame?.size.height)!
                self.collectionViewBottomAncher?.constant = -(endFrame?.size.height)! - 40
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}

//MARK: - Setup
extension ChatOnebyOneController {
    fileprivate func setup() {
        
        setupBackButton()
        setupContainerProfile()
        setupCollectionView()
        setupInputContainerView()
    }
    
    private func setupInputContainerView() {
        view.addSubview(inputContainerView)
        
        inputContainerView.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.8).isActive = true
        inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputContainerBottomAncher = inputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        inputContainerBottomAncher?.isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        inputContainerView.inputTextField.delegate = self
    }
    
    private func setupCollectionView() {
        
        
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.dataSource = self
        collectionView.delegate = self
//        collectionView.keyboardDismissMode = .interactive
        view.addSubview(collectionView)
        
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: containerProfileView.bottomAnchor, constant: 5).isActive = true
        collectionViewBottomAncher = collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        collectionViewBottomAncher?.isActive = true
    }
    
    fileprivate func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }
    
    fileprivate func setupContainerProfile() {
        
        view.addSubview(containerProfileView)
        
        containerProfileView.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.8).isActive = true
        containerProfileView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        containerProfileView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 5).isActive = true
        containerProfileView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        containerProfileView.addSubview(profileImageView)
        containerProfileView.addSubview(userNameLabel)
        containerProfileView.addSubview(seperaterView)
        containerProfileView.addSubview(dateLabel)
        
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.topAnchor.constraint(equalTo: containerProfileView.topAnchor).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: containerProfileView.leftAnchor).isActive = true
        
        userNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        userNameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        userNameLabel.rightAnchor.constraint(equalTo: containerProfileView.rightAnchor).isActive = true
        
        seperaterView.widthAnchor.constraint(equalTo: containerProfileView.widthAnchor).isActive = true
        seperaterView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        seperaterView.centerXAnchor.constraint(equalTo: containerProfileView.centerXAnchor).isActive = true
        seperaterView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 7).isActive = true
        
        dateLabel.centerXAnchor.constraint(equalTo: containerProfileView.centerXAnchor).isActive = true
        dateLabel.widthAnchor.constraint(equalTo: containerProfileView.widthAnchor).isActive = true
        dateLabel.topAnchor.constraint(equalTo: seperaterView.bottomAnchor).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: containerProfileView.bottomAnchor).isActive = true
        
    }
    
    fileprivate func setupBackground() {
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

//MARK: - fetchData
extension ChatOnebyOneController {
    
    fileprivate func fetchData() {
        fetchChatUser()
        observeMessages()
    }
    
    fileprivate func fetchChatUser() {
        
        if let profilePictureStr = chatUser?.profilePictureURL {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profilePictureStr)
        } else {
            profileImageView.image = UIImage(named: AssetName.profilePlaceholder.rawValue)
        }
        userNameLabel.text = chatUser?.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        let date = Date()
        dateLabel.text = dateFormatter.string(from: date)
        
    }
    
    fileprivate func observeMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid, let toId = chatUser?.userId else {
            return
        }
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                self.messages.append(Message(dictionary: dictionary))
                
                DispatchQueue.main.async {
                    print("collectionView reloaddata")
                    self.collectionView.reloadData()
                    
                    //scroll to the last index
                    
                    let indexpath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView.scrollToItem(at: indexpath, at: .bottom, animated: true)
                    
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }

    
}

//MARK: - handleChat
extension ChatOnebyOneController {
    
    func handleSend() {
        let text = inputContainerView.inputTextField.text!
        let properties = ["text": text] as [String : AnyObject]
        print("chat", properties)
        sendMessageWithProperties(properties: properties, newMessage: text)
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        
        let properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : AnyObject]
        
        sendMessageWithProperties(properties: properties, newMessage: "Shared Image")
        
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject], newMessage: String) {
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = chatUser!.userId
        let fromId = Auth.auth().currentUser!.uid
        
        let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        let isRead = false
        
        var values = ["toId": toId!, "fromId": fromId, "timestamp": timestamp, "isRead": isRead] as [String : AnyObject]
        
        
        //append properties dictionary onto values somehow??
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        //        childRef.updateChildValues(values)
        
        
        
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId!)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1, "lastSeenTimeStamp": timestamp])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId!).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
            
            if let toUserId = toId {
                self.handlePushToUser(toUserId, message: newMessage)
            }
        }
        
        
    }

    private func handlePushToUser(_ toUserId: String, message: String) {
        
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        let usersRef = Database.database().reference().child("users")
        
        usersRef.child(toUserId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                if let isLogIn = dictionary["isLogIn"] as? NSNumber, let pushToken = dictionary["pushToken"] as? String {
                    
                    if isLogIn == 0 {
                        
                        usersRef.child(fromId).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if let dictionary = snapshot.value as? [String: AnyObject] {
                                
                                if let userName = dictionary["name"] as? String {
                                    if pushToken != "" {
                                        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                                        let pushId = status.subscriptionStatus.pushToken
                                        
                                        if pushId != nil {
                                            let notificationContent = [
                                                "app_id": "65e296d1-6448-4989-b9fc-849eb21b218b",
                                                "include_player_ids": [pushToken],
                                                "contents": ["en": userName + ": " + message], // Required unless "content_available": true or "template_id" is set
                                                "headings": ["en": "New Message"],
                                                
                                                "ios_badgeType": "Increase",
                                                "ios_badgeCount": 1,
                                                "data": ["action": "chatting"]
                                                ] as [String : Any]
                                            
                                            //                                OneSignal.postNotification(notificationContent)
                                            OneSignal.postNotification(notificationContent, onSuccess: { (result) in
                                                
                                                print("onesignal sucess: ", result ?? "")
                                                
                                            }, onFailure: { (error) in
                                                
                                                print("onesignal error: ", error!)
                                                
                                            })
                                        }
                                    }
                                }
                            }
                        }, withCancel: nil)
                    }
                }
            }
        }, withCancel: nil)
        
        
        
    }
    
    func handleUploadTap() {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL{
            
            
            //we selected video
            
            handleVideoSelectedForUrl(url: videoUrl as URL)
            
            
        } else {
            
            //we selected an image
            handleImageSelectedForInfo(info: info as [String : AnyObject])
            
        }
        
        
        dismiss(animated: true, completion: nil)
        
    }
    private func handleVideoSelectedForUrl(url: URL) {
        
        let filename = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from: url as URL, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("Failed upload of video!", error!)
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                //                print(videoUrl)
                
                //all we are missing now is imageUrl
                if let thumbmailImage = self.thumbmailImageForFileUrl(fileUrl: url) {
                    
                    self.uploadToFirebaseStorageUsingImage(image: thumbmailImage, completiion: { (imageUrl) in
                        
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbmailImage.size.width as AnyObject, "imageHeight": thumbmailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject]
                        
                        self.sendMessageWithProperties(properties: properties, newMessage: "Shared Video")
                        
                    })
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            
            if let completeUniCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completeUniCount)
            }
            
        }
        uploadTask.observe(.success) { (snapshot) in
            
            self.navigationItem.title = self.chatUser?.name
            
        }
        
        
    }
    
    private func thumbmailImageForFileUrl(fileUrl: URL) -> UIImage? {
        
        
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
            let thumbmailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbmailCGImage)
            
        } catch let err {
            print(err)
        }
        
        
        return nil
    }
    
    private func handleImageSelectedForInfo(info: [String: AnyObject]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            uploadToFirebaseStorageUsingImage(image: selectedImage, completiion: { (imageUrl) in
                
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
                
                
            })
        }
        
        
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completiion: @escaping (_ imageUrl: String) -> ()) {
        
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image", error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    completiion(imageUrl)
                    
                }
                
            })
            
        }
        
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
}

//MARK: - handleImage, Video
extension ChatOnebyOneController {
    
    
    
    //my custom zooming logic
    
    func performZoomingForStartingImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                //math?
                //h2 / w2 = h1 / w1
                // h2 = h1 / w1 * w2
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                
                //                zoomOutImageView.removeFromSuperview()
                
            })
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view {
            
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.layer.masksToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed) in
                
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                
            })
        }
    }
}














