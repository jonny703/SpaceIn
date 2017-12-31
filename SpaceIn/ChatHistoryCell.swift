//
//  ChatHistoryCell.swift
//  SpaceIn
//
//  Created by John Nik on 11/15/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import Firebase

class ChatHistoryCell: UITableViewCell {
    
    var message: Message? {
        
        didSet {
            
            setupNameAndProfileImage()
            
            self.detailTextLabel?.text = message?.text != nil ? message?.text : "shared photo"
            
            
            
            if let seconds = message?.timestamp?.doubleValue {
                
                let timestampeDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                
                //                timeLabel.text = timestampeDate.description
                timeLabel.text = dateFormatter.string(from: timestampeDate as Date)
                timeLabel.text = returnLeftTimedateformatter(date: seconds)
            }
            
            if let messageCount = message?.newMessageCount {
                
                self.badgeLabel.text = String(messageCount)
                self.badgeLabel.isHidden = false
            } else {
                self.badgeLabel.isHidden = true
            }
        }
        
    }
    
    private func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            
            let ref = Database.database().reference().child("users").child(id)
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profilePictureURL"] as? String {
                        
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    } else {
                        self.profileImageView.image = UIImage(named: AssetName.profilePlaceholder.rawValue)
                    }
                    
                    let status = dictionary["isLogIn"] as? NSNumber
                    
                    self.statusImageView.isHidden = status == 1 ? false : true
                    
                }
                
                
            }, withCancel: nil)
        }
        
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: (textLabel?.frame.height)!)
        
        detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        
    }
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.profilePlaceholder.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
        
    }()
    
    let statusImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: AssetName.statusIcon.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.layer.cornerRadius = 20
//        imageView.layer.masksToBounds = true
//        imageView.contentMode = .scaleAspectFill
        return imageView
        
    }()
    
    let timeLabel: UILabel = {
        
        let label = UILabel()
        //        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    let badgeLabel: UILabel = {
        
        let label = UILabel()
        label.text = "0"
        label.textColor = .white
//        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .center
        label.backgroundColor = .red
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.textLabel?.textColor = UIColor.white
        self.detailTextLabel?.textColor = UIColor.white
        self.selectionStyle = .none
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(statusImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        statusImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        statusImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        statusImageView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        statusImageView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: statusImageView.leftAnchor, constant: -3).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
        
        
        addSubview(badgeLabel)
        
        badgeLabel.widthAnchor.constraint(equalToConstant: 16).isActive = true
        badgeLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        badgeLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor, constant: 14.14).isActive = true
        badgeLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 14.14).isActive = true
    }
    
    override func prepareForReuse() {
        self.profileImageView.image = nil
        super.prepareForReuse()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


