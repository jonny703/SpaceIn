//
//  SpaceInConvenience.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import MapKit

public extension UIView {
    convenience init(asConstrainable: Bool, frame: CGRect) {
        self.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = !asConstrainable
    }
    
    public func constrainWidthAndHeightToValueAndActivate(value: CGFloat) {
        self.widthAnchor.constraint(equalToConstant: value).isActive = true
        self.heightAnchor.constraint(equalToConstant: value).isActive = true
    }
    
    public func constrainPinInside(view: UIView) {
        self.makeConstrainable()
        
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    public func constrainCenterInside(view: UIView) {
        self.makeConstrainable()
        
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    public func constrainToHeight(height: CGFloat) {
        self.makeConstrainable()
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    public func constrainToWidth(width: CGFloat) {
        self.makeConstrainable()
        self.widthAnchor.constraint(equalToConstant: width)
    }
    
    public func makeConstrainable() {
        if self.translatesAutoresizingMaskIntoConstraints == true {
            print("You are trying to constrain a view that is not constrainable \(self)")
        }
    }
    
}

extension UILabel {
    convenience init(asConstrainable: Bool, frame: CGRect) {
        self.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = !asConstrainable
    }
}

extension UIImageView {
    convenience init(asConstrainable: Bool) {
        self.init(frame: CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = !asConstrainable
    }
    
    convenience init(image: UIImage?, asConstrainable: Bool) {
        self.init(image: image)
        self.translatesAutoresizingMaskIntoConstraints = !asConstrainable
    }
    
    convenience init(image: UIImage?, highlightedImage: UIImage?, constrainable: Bool) {
        self.init(image: image, highlightedImage: highlightedImage)
        self.translatesAutoresizingMaskIntoConstraints = !constrainable
    }
}

extension CLLocationCoordinate2D {
    func isEqualToCoordinate(coordinate: CLLocationCoordinate2D) -> Bool {
        return self.latitude == coordinate.latitude && self.longitude == coordinate.longitude
    }
}

extension UIColor {
    convenience init(withNumbersFor red: CGFloat , green: CGFloat, blue: CGFloat, alpha: CGFloat? = 1.0) {
        let redNumber = red / 255
        let greenNumber = green / 255
        let blueNumber = blue / 255
        
        self.init(red: redNumber , green: greenNumber, blue: blueNumber, alpha: alpha!)
    }
}


extension UIViewController {
    func addChild(viewController: UIViewController) {
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
    }
}


extension String {
    func isValidString() -> Bool {
        return self.characters.count > 0
    }
    
    func validString() -> String? {
        return self.isValidString() ? self : nil
    }
}


extension UIImage {
    func normalizedImage() -> UIImage? {
        
        if (self.imageOrientation == UIImageOrientation.up) {
            return self;
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let normalizedImage : UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
}
