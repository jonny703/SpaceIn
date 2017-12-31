//
//  PostReplyCell.swift
//  SpaceIn
//
//  Created by John Nik on 11/15/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import AVFoundation

class PostReplyCell: UICollectionViewCell {
    
    var postReplyController: PostReplyController?
    
    var post: Post?
    
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
            
            self.postReplyController?.performZoomingForStartingImageView(startingImageView: imageView)
        }
        
        
    }
    
    var postImageViewConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//                self.backgroundColor = .red
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        addSubview(postImageView)
        
        //        messageImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        postImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -DEVICE_WIDTH * 0.2).isActive = true
        postImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: DEVICE_WIDTH * 0.3).isActive = true
        postImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -18).isActive = true
        postImageViewConstraint = postImageView.heightAnchor.constraint(equalToConstant: 150)
        postImageViewConstraint?.isActive = true
        
        
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: DEVICE_WIDTH * 0.1 + 15).isActive = true
        
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        
        bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -DEVICE_WIDTH * 0.1).isActive = true
        bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: DEVICE_WIDTH * 0.1).isActive = true
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 0).isActive = true
        
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 45).isActive = true
        
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -5).isActive = true
        textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor, constant: -24).isActive = true
        
        
        timeLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        timeLabel.topAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        
        
    }
    
    override func prepareForReuse() {
        self.profileImageView.image = nil
        super.prepareForReuse()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

