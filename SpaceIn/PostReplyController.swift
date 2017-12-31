//
//  PostReplyController.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class PostReplyController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let cellId = "cellId"
    var postUser: SpaceUser? {
        didSet {
//            fetchData()
        }
        
    }
    var posts = [Post]()
    var currentPost: Post?
    
    var startingFrame: CGRect?
    
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    var inputContainerBottomAncher: NSLayoutConstraint?
    var collectionViewBottomAncher: NSLayoutConstraint?
    
    var postImageViewConstraint: NSLayoutConstraint?
    var containerProfileViewConstraint: NSLayoutConstraint?
    
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
        self.dismiss(animated: true, completion: nil)
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
        return colView
    }()
    
    let containerProfileView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textView: UITextView = {
        
        let tv = UITextView()
        tv.text = "sdfs"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.black
        tv.isEditable = false
        tv.textAlignment = .center
        tv.isUserInteractionEnabled = false
        //        tv.backgroundColor = .blue
        return tv
        
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "23:34 AM"
        label.textColor = .black
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        //        view.layer.cornerRadius = 16
        //        view.layer.masksToBounds = true
        return view
        
    }()
    
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.profilePlaceholder.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 22.5
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 1.5
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
        
    }()
    
    lazy var postImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //        imageView.layer.cornerRadius = 16
        //        imageView.layer.masksToBounds = true
        //        imageView.contentMode = .scaleAspectFill
        //        imageView.backgroundColor = UIColor.brown
        
        imageView.isUserInteractionEnabled = true
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        return imageView
        
    }()
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        
        if let imageView = tapGesture.view as? UIImageView {
            
            //PRO Tip: don't perform a lot of custom logic inside of a view class
            
            self.performZoomingForStartingImageView(startingImageView: imageView)
        }
    }
    
    lazy var inputContainerView: ChatInputContainerView = {
        
        let chatInputContainerview = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: 40))
        
        chatInputContainerview.postReplyController = self
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
        fetchData()
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func handleKeyboardDidShow() {
        
        if posts.count > 0 {
            
            let indexPath = IndexPath(item: posts.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            
        }
        
    }
    
    
}


//MARK: handle collection view delegate

extension PostReplyController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        //orientaion enable
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PostReplyCell
        cell.postReplyController = self
        
        let post = posts[indexPath.item]
        
        cell.post = post
        
        cell.textView.text = post.text
        
        if let seconds = post.timestamp?.doubleValue {

            
            let timestampeDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            
            //                timeLabel.text = timestampeDate.description
            cell.timeLabel.text = dateFormatter.string(from: timestampeDate as Date)
            cell.timeLabel.text = returnLeftTimedateformatter(date: seconds)
            
        }
        
        
        setupCell(cell: cell, post: post)
        
        
        if let text = post.text {
            
            cell.textView.isHidden = false
            
        } else {
            cell.textView.isHidden = true
        }
        
        if post.imageUrl != nil {
            cell.postImageView.isHidden = false
        } else {
            cell.postImageView.isHidden = true
        }
        cell.setNeedsDisplay()
        return cell
        
    }
    
    private func setupCell(cell: PostReplyCell, post: Post) {
        
        if let id = post.fromId {
            
            let ref = Database.database().reference().child("users").child(id)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    if let profileImageUrl = dictionary["profilePictureURL"] as? String {
                        
                        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    } else {
                        cell.profileImageView.image = UIImage(named: AssetName.profilePlaceholder.rawValue)
                    }
                }
            }, withCancel: nil)
        }
        
        if let postImageUrl = post.imageUrl {
            cell.postImageView.loadImageUsingCacheWithUrlString(urlString: postImageUrl)
            cell.postImageView.isHidden = false
            
            if let imageWidth = post.imageWidth?.floatValue, let imageHeight = post.imageHeight?.floatValue {
                
                cell.postImageViewConstraint?.constant = CGFloat(imageHeight / imageWidth * Float(DEVICE_WIDTH) * 0.5)
            }
            
        } else {
            cell.postImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 65
        
        let post = posts[indexPath.item]
        
        if let text = post.text {
            
            height = estimateFrameForText(text: text).height + 42.5
            
        } else {
            height = 17.5
        }
        
        if let imageWidth = post.imageWidth?.floatValue, let imageHeight = post.imageHeight?.floatValue {
            
            height += CGFloat(imageHeight / imageWidth * Float(DEVICE_WIDTH) * 0.5)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
        
    }
    
    fileprivate func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: DEVICE_WIDTH * 0.8 - 50, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let post = posts[indexPath.item]
        
        if post.fromId != Auth.auth().currentUser?.uid {
            let userRef = Database.database().reference().child("users").child(post.fromId!)
            
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let user = SpaceUser()
                    user.userId = snapshot.key
                    user.setValuesForKeys(dictionary)
                    
                    let profileVC = UserProfileController(user: user)
                    profileVC.postReplyController = self
                    profileVC.controllerStauts = .postReplyController
                    
                    profileVC.modalPresentationStyle = .overCurrentContext
                    profileVC.modalTransitionStyle = .crossDissolve
                    self.present(profileVC, animated: false, completion: nil)
                    
                }
                
                
            }, withCancel: nil)
        }
        
        
    }
    
}

//MARK handel chatonebyone controller

extension PostReplyController {
    func presentChatOnebyOneController(user: SpaceUser) {
        let chatOnebyOneController = ChatOnebyOneController()
        chatOnebyOneController.chatUser = user
        chatOnebyOneController.modalPresentationStyle = .overCurrentContext
        chatOnebyOneController.modalTransitionStyle = .crossDissolve
        self.present(chatOnebyOneController, animated: false, completion: nil)
    }
}

//MARK: - handleKeyboard
extension PostReplyController {
    
    
    
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
extension PostReplyController {
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
        
        
        collectionView.register(PostReplyCell.self, forCellWithReuseIdentifier: cellId)
    
        collectionView.dataSource = self
        collectionView.delegate = self
        //        collectionView.keyboardDismissMode = .interactive
        view.addSubview(collectionView)
        
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: containerProfileView.topAnchor, constant: 5).isActive = true
        collectionViewBottomAncher = collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        collectionViewBottomAncher?.isActive = true
    }
    
    fileprivate func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }
    
    fileprivate func setupContainerProfile() {
        
        view.addSubview(containerProfileView)
        
        containerProfileView.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.8).isActive = true
        containerProfileViewConstraint = containerProfileView.heightAnchor.constraint(equalToConstant: 150)
        containerProfileViewConstraint?.isActive = true
        containerProfileView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 5).isActive = true
        containerProfileView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        containerProfileView.addSubview(bubbleView)
        containerProfileView.addSubview(textView)
        containerProfileView.addSubview(profileImageView)
        containerProfileView.addSubview(timeLabel)
        
        containerProfileView.addSubview(postImageView)
        
        //        messageImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        postImageView.rightAnchor.constraint(equalTo: containerProfileView.rightAnchor, constant: 0).isActive = true
        postImageView.leftAnchor.constraint(equalTo: containerProfileView.leftAnchor, constant: 65).isActive = true
        postImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -18).isActive = true
        postImageViewConstraint = postImageView.heightAnchor.constraint(equalToConstant: 150)
        postImageViewConstraint?.isActive = true
        
        
        
        profileImageView.leftAnchor.constraint(equalTo: containerProfileView.leftAnchor, constant: 0).isActive = true
        profileImageView.topAnchor.constraint(equalTo: containerProfileView.topAnchor, constant: 0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        
        bubbleView.rightAnchor.constraint(equalTo: containerProfileView.rightAnchor, constant: 0).isActive = true
        bubbleView.leftAnchor.constraint(equalTo: containerProfileView.leftAnchor, constant: 0).isActive = true
        
        bubbleView.topAnchor.constraint(equalTo: containerProfileView.topAnchor, constant: 22.5).isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: containerProfileView.heightAnchor, constant: -22.5).isActive = true
        
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 45).isActive = true
        
        textView.topAnchor.constraint(equalTo: containerProfileView.topAnchor, constant: 29).isActive = true

        
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -5).isActive = true
        textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor, constant: -24).isActive = true
        
        
        timeLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        timeLabel.topAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        
        containerProfileView.isHidden = true
        
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
extension PostReplyController {
    
    fileprivate func fetchData() {
        fetchPostUser()
        observePosts()
    }
    
    fileprivate func fetchPostUser() {
        
        var height: CGFloat = 65
        
        if let text = currentPost?.text {
            self.textView.text = text
            self.textView.isHidden = false
            height = estimateFrameForText(text: text).height + 65
            
        } else {
            height = 40
            self.textView.isHidden = true
        }
        
        if currentPost?.imageUrl != nil {
            self.postImageView.isHidden = false
        } else {
            self.postImageView.isHidden = true
        }

        
        if let profilePictureStr = postUser?.profilePictureURL {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profilePictureStr)
        } else {
            profileImageView.image = UIImage(named: AssetName.profilePlaceholder.rawValue)
        }
        
        if let postImageUrl = currentPost?.imageUrl {
            self.postImageView.loadImageUsingCacheWithUrlString(urlString: postImageUrl)
            self.postImageView.isHidden = false
            
            if let imageWidth = currentPost?.imageWidth?.floatValue, let imageHeight = currentPost?.imageHeight?.floatValue {
                
                self.postImageViewConstraint?.constant = CGFloat(imageHeight / imageWidth * Float(DEVICE_WIDTH) * 0.8)
                height += CGFloat(imageHeight / imageWidth * Float(DEVICE_WIDTH) * 0.8)
            }
            
        } else {
            self.postImageView.isHidden = true
        }
        
        if let seconds = currentPost?.timestamp?.doubleValue {
            
            
            let timestampeDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            timeLabel.text = dateFormatter.string(from: timestampeDate as Date)
            
        }


        containerProfileViewConstraint?.constant = height
    }
    
    fileprivate func observePosts() {
        
        guard let currentPostId = currentPost?.postId else {
            return
        }
        
        self.posts.append(currentPost!)
        
        let userMessagesRef = Database.database().reference().child("post-replys").child(currentPostId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let postId = snapshot.key
            let messagesRef = Database.database().reference().child("posts").child(postId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                self.posts.append(Post(dictionary: dictionary))
                
                DispatchQueue.main.async {
                    print("collectionView reloaddata")
                    self.collectionView.reloadData()
                    
                    //scroll to the last index
                    
                    let indexpath = IndexPath(item: self.posts.count - 1, section: 0)
                    self.collectionView.scrollToItem(at: indexpath, at: .bottom, animated: true)
                    
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
}

//MARK: - handleChat
extension PostReplyController {
    
    func handleSend() {
        
        let properties = ["text": inputContainerView.inputTextField.text!] as [String : AnyObject]
        print("chat", properties)
        sendMessageWithProperties(properties: properties)
        
        
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        
        let properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : AnyObject]
        
        sendMessageWithProperties(properties: properties)
        
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        
        let ref = Database.database().reference().child("posts")
        let childRef = ref.childByAutoId()
        
        let fromId = Auth.auth().currentUser!.uid
        
        let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        
        var values = ["postId": childRef.key, "fromId": fromId, "timestamp": timestamp] as [String : AnyObject]
        
        
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
            
            if let currentPostId = self.currentPost?.postId {
                let postReplyRef = Database.database().reference().child("post-replys").child(currentPostId)
                let postId = childRef.key
                postReplyRef.updateChildValues([postId: 1])
            }
        }
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
                        
                        self.sendMessageWithProperties(properties: properties)
                        
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
            
            self.navigationItem.title = self.postUser?.name
            
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
extension PostReplyController {
    
    
    
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


