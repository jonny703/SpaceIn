//
//  PostHistoryController.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import Firebase

class PostHistoryController: UIViewController {
    
    
    
    var postUser: SpaceUser? {
        didSet {
            observePosts()
        }
        
    }
    
    fileprivate var viewAppeared = false
    let cellId = "cellId"
    var posts = [Post]()
    
    //MARK set backgroud Ui when postImageView shows
    
    var startingFrame: CGRect?
    
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
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
        return colView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}


//MARK: fetch posts Data

extension PostHistoryController {
    
    fileprivate func observePosts() {
        
        guard let uid = postUser?.userId else {
            return
        }
        
        let userPostRef = Database.database().reference().child("user-posts").child(uid)
        
        userPostRef.observe(.childAdded, with: { (snapshot) in
            
            let postId = snapshot.key
            let postsRef = Database.database().reference().child("posts").child(postId)
            postsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let post = Post(dictionary: dictionary)
                
                let postedDay = returnDayWithDateformatter(date: post.timestamp as! Double)
                if postedDay < 7 {
//                    self.posts.append(Post(dictionary: dictionary))
                    
                    if postedDay != 0 {
                        self.posts.insert(Post(dictionary: dictionary), at: 0)
                        
                        DispatchQueue.main.async {
                            print("collectionView reloaddata")
                            self.collectionView.reloadData()
                            
                        }
                    }
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }

    
}


//MARK: handle collection view delegate

extension PostHistoryController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        //orientaion enable
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PostHistoryCell
        cell.postHistoryController = self
        
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
    
    private func setupCell(cell: PostHistoryCell, post: Post) {
        
        if let profileImageUrl = postUser?.profilePictureURL {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        } else {
            cell.profileImageView.image = UIImage(named: AssetName.profilePlaceholder.rawValue)
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
            
            height = estimateFrameForText(text: text).height + 65
            
        } else {
            height = 40
        }
        
        if let imageWidth = post.imageWidth?.floatValue, let imageHeight = post.imageHeight?.floatValue {
            
            height += CGFloat((imageHeight / imageWidth) * Float(DEVICE_WIDTH) * 0.5)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let post = posts[indexPath.item]
        
        let postReplyController = PostReplyController()
        postReplyController.postUser = self.postUser
        postReplyController.currentPost = post
        postReplyController.modalPresentationStyle = .overCurrentContext
        self.present(postReplyController, animated: true, completion: nil)
        
        
    }

    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: DEVICE_WIDTH * 0.8 - 50, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }

    
}


//MARK: handle dismiss controller

extension PostHistoryController {
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}


//MARK: setup Background

extension PostHistoryController {
    
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

//MARK: setup Views

extension PostHistoryController {
    
    fileprivate func setupViews() {
        setupBackButton()
        
        setupCollectionView()
    }
    
    fileprivate func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        backButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    }
    
    private func setupCollectionView() {
        
        
        collectionView.register(PostHistoryCell.self, forCellWithReuseIdentifier: cellId)
//        collectionView.dataSource = self
//        collectionView.delegate = self
        //        collectionView.keyboardDismissMode = .interactive
        view.addSubview(collectionView)
        
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 15).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }

}

//MARK: - handle postImage
extension PostHistoryController {
    
    
    
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
                
            }, completion: { (completed) in
                
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
                
            })
        }
    }
}


