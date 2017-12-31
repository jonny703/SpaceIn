//
//  UserAnnotationView.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//
import MapKit
import UIKit

//class UserAnnotationView: MKAnnotationView {
//    static let imageIdentifier = "mapProfile"
//    let pictureView = UIImageView(asConstrainable: false)
//    let pinView = UIImageView(asConstrainable: false)
//    weak var user: SpaceInUser?
//    
//    var mapProfileName: String?
//    
//    convenience init (annotation: MKAnnotation, user: SpaceInUser, mapProfileName: String) {
//        self.init(annotation: annotation, reuseIdentifier: user.uid)
//        
//        self.user = user
//        self.mapProfileName = mapProfileName
//        setup()
//    }
//    
//    private func setup() {
//        
//        addSubviews()
//        setupLayout()
//    }
//    
//    private func addSubviews() {
//        addSubview(pictureView)
//        addSubview(pinView)
//    }
//    
//    private func setupLayout() {
//        frame = CGRect(x: 0, y: 0, width: 75, height: 75)
//        contentMode = .scaleAspectFit
//        
//        setupPinView()
//        setupPictureView()
//        layer.anchorPoint = CGPoint(x: 0.5, y: 1)
//    }
//    
//    private func setupPictureView() {
//
//        let sidePadding = pinView.frame.size.width * 0.025
//        let circleBorderWidth = pinView.frame.size.width * 0.054
//        let diameter = pinView.frame.size.height * 0.9 - circleBorderWidth
//        
//        pictureView.frame = CGRect(x: sidePadding+circleBorderWidth, y: circleBorderWidth / 2, width: diameter, height: diameter)
//        
//        let placeholderImage = UIImage(named: AssetName.profilePlaceholder.rawValue)
//        pictureView.image = placeholderImage
//
//        if let profileImage = user?.image {
//            pictureView.image = profileImage
//        } else if let imageURL = user?.imageURL {
//            if let url = URL(string: imageURL) {
//                pictureView.sd_setImage(with: url, placeholderImage: placeholderImage!)
//            }
//        }
//                    
//        pictureView.contentMode = .scaleAspectFill
//        
//        pictureView.layer.cornerRadius = pictureView.frame.size.width / 2
//        pictureView.clipsToBounds = true
//        pictureView.backgroundColor = .white
//    }
//    
//    private func setupPinView() {
//        
//        pinView.frame = bounds
//        pinView.image = UIImage(named: self.mapProfileName!)
//        pinView.contentMode = .scaleAspectFit
//    }
//
//}
