//
//  CreatePostController.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//
import UIKit
import Firebase

class CreatePostController: UIViewController {
    
    fileprivate var viewAppeared = false
    
    fileprivate var isSelectedPhoto = false
    
    fileprivate let PlaceHolderText = "Write your post here..."
    fileprivate var postImageViewConstraint: NSLayoutConstraint?
    
    //MARK set UI
    
    fileprivate let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    var spinner : UIActivityIndicatorView?
    
    
    
    let backButton: UIButton = {
        
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.dismissX.rawValue)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        button.tintColor = .white
        return button
        
    }()
    
    let postButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Post", for: .normal)
        
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePost), for: .touchUpInside)
        return button
        
    }()
    
    
    
    let postTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.layer.cornerRadius = 6
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var inputContainerView: ChatInputContainerView = {
        
        let chatInputContainerview = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerview.containerView.isHidden = true
        chatInputContainerview.createPostController = self
        
        return chatInputContainerview
        
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupViews()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        postTextView.text = PlaceHolderText
    }
    
    override var inputAccessoryView: UIView? {
        
        get {
            return inputContainerView
        }
        
    }
    
    override var canBecomeFirstResponder: Bool {
        
        return true
        
    }

}



//MARK: handle post and dismiss controller

extension CreatePostController {
    
    func handlePost() {
        
        self.addSpinner()
        
        if isSelectedPhoto == true {
            handlePostImage()
        } else {
            
            if postTextView.text == PlaceHolderText {
                self.stopSpinner()
                showAlertMessage(vc: self, titleStr: "Oops! Can't post", messageStr: "Please fill out content")
                return
            }
            
            let properties = ["text": postTextView.text!] as [String : AnyObject]
            
            sendMessageWithProperties(properties: properties)
        }
    }
    
    fileprivate func handlePostImage() {
        
        uploadToFirebaseStorageUsingImage(image: postImageView.image!, completiion: { (imageUrl) in
            
            self.sendMessageWithImageUrl(imageUrl: imageUrl, image: self.postImageView.image!)
            
        })
    }

    private func uploadToFirebaseStorageUsingImage(image: UIImage, completiion: @escaping (_ imageUrl: String) -> ()) {
        
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("post_images").child(imageName)
        
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
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        var properties: [String: AnyObject]
        if postTextView.text == "" || postTextView.text == PlaceHolderText {
            properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : AnyObject]
        } else {
            properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height, "text": postTextView.text!] as [String : AnyObject]
        }
        
        
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
            
            self.postTextView.text = nil
            
            let userPostsRef = Database.database().reference().child("user-posts").child(fromId)
            
            let postId = childRef.key
            userPostsRef.updateChildValues([postId: 1])
            
            self.stopSpinner()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: handle spinner

extension CreatePostController {
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

//MARK: uiImagePickerDelegate, handle post Image

extension CreatePostController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    func handleSelectPostImageView() {
        
        let alertController = UIAlertController(title: "What would you like?", message: "", preferredStyle: .actionSheet)
        
        let photoGalleryAction = UIAlertAction(title: "Chose a Picture", style: .default) { (action) in
            
            let picker = UIImagePickerController()
            
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            picker.sourceType = .savedPhotosAlbum
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                
                picker.modalPresentationStyle = .popover
                picker.popoverPresentationController?.delegate = self
                //                picker.popoverPresentationController?.sourceView = self.view
                self.present(picker, animated: true, completion: nil)
                
            } else {
                self.present(picker, animated: true, completion: nil)
            }
            
            
        }
        
        let cameraAction = UIAlertAction(title: "Take a Picture", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.sourceType = .camera
                picker.cameraCaptureMode = .photo
                picker.modalPresentationStyle = .fullScreen
                
                
                if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                    
                    picker.modalPresentationStyle = .popover
                    picker.popoverPresentationController?.delegate = self
                    //                    picker.popoverPresentationController?.sourceView = self.view
                    self.present(picker, animated: true, completion: nil)
                    
                } else {
                    self.present(picker, animated: true, completion: nil)
                }
                
                
                
            } else {
                self.noCamera()
            }
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(photoGalleryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            
            alertController.modalPresentationStyle = .popover
            alertController.popoverPresentationController?.delegate = self
            //            alertController.popoverPresentationController?.sourceView = view
            present(alertController, animated: true, completion: nil)
            
            
        } else {
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        
        popoverPresentationController.sourceView = postImageView
        popoverPresentationController.sourceRect = postImageView.bounds
        popoverPresentationController.permittedArrowDirections = .up
    }
    
    
    func noCamera() {
        
        showAlertMessage(vc: self, titleStr: "No Camera", messageStr: "Sorry, this device has no camera")
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImmageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImmageFromPicker = editedImage
            
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImmageFromPicker = originalImage
            
        }
        
        if let selectedImage = selectedImmageFromPicker {
            postImageView.image = selectedImage
            
            postImageViewConstraint?.constant = DEVICE_WIDTH *  0.9 * selectedImage.size.height / selectedImage.size.width
            isSelectedPhoto = true
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
        
    }

    
}


//MARK: textView delegate to use placeholder

extension CreatePostController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = PlaceHolderText
            textView.textColor = UIColor.lightGray
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }


    
}

//MARK: setup Background

extension CreatePostController {
    
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

extension CreatePostController {
    
    fileprivate func setupViews() {
        setupBackButton()
        setupPostTextView()
        setupPostImageView()
        setupPostButton()
    }
    
    fileprivate func setupPostButton() {
        
        view.addSubview(postButton)
        
        postButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        postButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        postButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
    }
    
    fileprivate func setupPostImageView() {
        view.addSubview(postImageView)
        postImageView.widthAnchor.constraint(equalTo: postTextView.widthAnchor).isActive = true
        postImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        postImageView.topAnchor.constraint(equalTo: postTextView.bottomAnchor, constant: 3).isActive = true
        postImageViewConstraint = postImageView.heightAnchor.constraint(equalToConstant: 100)
        postImageViewConstraint?.isActive = true
    }
    
    fileprivate func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }
    
    fileprivate func setupPostTextView() {
        postTextView.delegate = self
        
        view.addSubview(postTextView)
        
        postTextView.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.9).isActive = true
        postTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        postTextView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 5).isActive = true
        postTextView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        postTextView.text = PlaceHolderText
        postTextView.textColor = UIColor.lightGray
    }
    
}


