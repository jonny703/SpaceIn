//
//  ChatInputContainerView.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    var chatOnebyOneController: ChatOnebyOneController? {
        
        didSet {
            sendButton.addTarget(chatOnebyOneController, action: #selector(chatOnebyOneController?.handleSend), for: .touchUpInside)
            
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatOnebyOneController, action: #selector(chatOnebyOneController?.handleUploadTap)))
        }
    }
    
    var createPostController: CreatePostController? {
        
        didSet {
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: createPostController, action: #selector(createPostController?.handleSelectPostImageView)))
        }
        
    }
    
    var postReplyController: PostReplyController? {
        didSet {
            sendButton.addTarget(postReplyController, action: #selector(postReplyController?.handleSend), for: .touchUpInside)
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: postReplyController, action: #selector(postReplyController?.handleUploadTap)))
        }
    }
    
    let uploadImageView: UIImageView = {
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: AssetName.plusButton.rawValue)
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        return uploadImageView
        
    }()
    
    lazy var inputTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Text Goes Here..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
        
    }()
    
    let sendButton: UIButton = {
        
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.sendButton.rawValue)
        button.setBackgroundImage(image, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button

        
    }()
    
    let containerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
//    let uploadImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        //what is handle?
//        sendButton.addTarget(self, action: #selector(self.chatLogController?.handleSend), for: .touchUpInside)
        
        
        addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 7).isActive = true
        containerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -3).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        containerView.addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
//        let seperatorLineView = UIView()
//        seperatorLineView.backgroundColor = UIColor.black
//        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(seperatorLineView)
//        
//        seperatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        seperatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        seperatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatOnebyOneController?.handleSend()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
