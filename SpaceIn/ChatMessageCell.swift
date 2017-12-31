//
//  ChatMessageCell.swift
//  SpaceIn
//
//  Created by John Nik on 11/15/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    var chatOnebyOneController: ChatOnebyOneController?
    
    var message: Message?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        
        let button = UIButton(type: UIButtonType.system)
        let image = UIImage(named: AssetName.playButton.rawValue)
        button.setBackgroundImage(image, for: .normal)
//        button.setTitle("play", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)

        return button
        
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    func handlePlay() {
        
        if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) {
            
            player = AVPlayer(url: url)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            
            player?.play()
            
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
            print("Attempting to play video...")
            
        }
        
        
    }
    
    
    //player stopped when scroll starting
    override func prepareForReuse() {
        
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
        
    }
    
    let textView: UITextView = {
        
        let tv = UITextView()
        tv.text = "sdfs"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
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
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        
        let view = UIView()
//        view.backgroundColor = blueColor
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
    
    lazy var messageImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
//        imageView.backgroundColor = UIColor.brown
        
        imageView.isUserInteractionEnabled = true
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        return imageView
        
    }()
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        
        if message?.videoUrl != nil {
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView {
            
            //PRO Tip: don't perform a lot of custom logic inside of a view class
            self.chatOnebyOneController?.performZoomingForStartingImageView(startingImageView: imageView)
            
        }
        
        
    }
    
    var bubbleWidthAncher: NSLayoutConstraint?
    
    var bubbleViewRightAncher: NSLayoutConstraint?
    var bubbleViewLeftAncher: NSLayoutConstraint?
    
    var profileImageViewRightAncher: NSLayoutConstraint?
    var profileImageViewLeftAncher: NSLayoutConstraint?
    
    var textViewRightAncher: NSLayoutConstraint?
    var textViewLeftAncher: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = .red
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        bubbleView.addSubview(messageImageView)
        
//        messageImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        bubbleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        bubbleView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 45).isActive = true

        
        
        profileImageViewLeftAncher = profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: DEVICE_WIDTH * 0.1)
        profileImageViewLeftAncher?.isActive = true
        
        profileImageViewRightAncher = profileImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -DEVICE_WIDTH * 0.1)
        profileImageViewRightAncher?.isActive = false
        
        
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        bubbleViewRightAncher =  bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -DEVICE_WIDTH * 0.1)
        bubbleViewRightAncher?.isActive = true
        
        bubbleViewLeftAncher = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: DEVICE_WIDTH * 0.1)
        bubbleViewLeftAncher?.isActive = false
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 22.5).isActive = true
        bubbleWidthAncher = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAncher?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -22.5).isActive = true
        
//        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textViewLeftAncher = textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 0)
        textViewLeftAncher?.isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 29).isActive = true
        
        textViewRightAncher = textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 0)
        textViewRightAncher?.isActive = true
//        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor, constant: -24).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        timeLabel.topAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
