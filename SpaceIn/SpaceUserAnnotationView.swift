//
//  SpaceUserAnnotationView.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import MapKit
import UIKit

class SpaceUserAnnotationView: MKAnnotationView {
    static let imageIdentifier = "mapProfile"
    weak var user: SpaceUser?
    
    var mapProfileName: String?
    
    convenience init (annotation: MKAnnotation, user: SpaceUser, mapProfileName: String) {
        
        self.init(annotation: annotation, reuseIdentifier: user.userId)
        
        self.user = user
        self.mapProfileName = mapProfileName
        setup()
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        
        
        
    }
    
    private func setupCurrentUser() {
        let pinImage = UIImage(named: self.mapProfileName!)
        let size = CGSize(width: 35, height: 35)
        self.image = self.resizedProfileImagesWith(image: pinImage!, size: size)
        
    }
    
    private func setup() {
        
        var profileImage = UIImage()
        
        if let profilePictureStr = user?.profilePictureURL {
            let url = URL(string: (profilePictureStr))
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.sync {
                    if let downloadedImage = UIImage(data: data!) {
                        profileImage = downloadedImage
                        self.image = self.customizeMarkerView(withImage: profileImage)
                    }
                }
                
            }).resume()
        } else {
            profileImage = UIImage(named: AssetName.profilePlaceholder.rawValue)!
            self.image = self.customizeMarkerView(withImage: profileImage)
        }
        
        
    }
    
    fileprivate func resizedProfileImagesWith(image: UIImage, size: CGSize) -> UIImage {
        
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
    
    func customizeMarkerView(withImage profileImage: UIImage) -> UIImage{
        
        var viewHeight = 53.4
        var imageXDistance: CGFloat = 1.8
        var imageYDistance: CGFloat = 5.0
        if self.mapProfileName == AssetName.transparentPin.rawValue {
            viewHeight = 52.5
            imageXDistance = 0
            imageYDistance = 0
        }
        
        
        
        ///Creating UIView for Custom Marker
        let DynamicView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: viewHeight))
        DynamicView.backgroundColor = UIColor.clear
        
        //Creating Marker Pin imageview for Custom Marker
        var imageViewForPinMarker : UIImageView
        let pinImage = UIImage(named: mapProfileName!)
        let height = pinImage?.size.height
        let width = pinImage?.size.width
        imageViewForPinMarker  = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45 * height! / width!))
        imageViewForPinMarker.image = pinImage
        
        //Creating User Profile imageview
        var imageViewForUserProfile : UIImageView
        imageViewForUserProfile  = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageViewForUserProfile.contentMode = .scaleAspectFill
        imageViewForUserProfile.image = profileImage
        imageViewForUserProfile.center.x = imageViewForPinMarker.center.x + imageXDistance
        imageViewForUserProfile.center.y = imageViewForPinMarker.center.y - 45 * (height! / width! - 1) / 2 + imageYDistance
        imageViewForUserProfile.layer.cornerRadius = 20
        imageViewForUserProfile.layer.masksToBounds = true
        
        //Adding userprofile imageview inside Marker Pin Imageview
        imageViewForPinMarker.addSubview(imageViewForUserProfile)
        
        if  self.user?.postCount != 0 {
            let label = UILabel()
            label.text = self.user?.postCount?.stringValue
            label.sizeToFit()
            print(label.text!)
            label.font = UIFont.systemFont(ofSize: 8)
            label.textAlignment = .center
            label.center.x = imageViewForPinMarker.center.x - 14.5
            label.center.y = imageViewForPinMarker.center.y - 18.5
            imageViewForPinMarker.addSubview(label)
            
        }

        
        //Adding Marker Pin Imageview isdie view for Custom Marker
        DynamicView.addSubview(imageViewForPinMarker)
        
        
        //Converting dynamic uiview to get the image/marker icon.
        UIGraphicsBeginImageContextWithOptions(DynamicView.frame.size, false, UIScreen.main.scale)
        DynamicView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageConverted: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return imageConverted
    }

    
}

