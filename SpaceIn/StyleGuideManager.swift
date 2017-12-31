//
//  StyleGuideManager.swift
//  SpaceIn
//
//  Created by John Nik on 11/15/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import UIKit


public class StyleGuideManager {
    private init(){}
    
    static let sharedInstance : StyleGuideManager = {
        let instance = StyleGuideManager()
        return instance
    }()
    
    //intro
    static let introBackgroundColor = UIColor(r: 0, g: 204, b: 253)
    
    //Login
    static let loginTextFieldDefaultColor = UIColor.white
    static let loginPlaceholderTextColor = UIColor.white

    static let loginTextFieldSelectedColor = UIColor(withNumbersFor: 36, green: 255, blue: 132)
    static let loginTextFieldTextColor = UIColor(withNumbersFor: 36, green: 217, blue: 255)
    
    static let loginButtonBorderColor = UIColor(red: 105 / 255 , green: 240 / 255, blue: 174 / 255, alpha: 1.0)
    static let loginPageTextColor = UIColor.white

    //Register
    static let registerPlaceholderTextColor = UIColor.lightGray
    static let registerTextFieldDefaultColor = UIColor(withNumbersFor: 16, green: 249, blue: 232)

    static let registerTextFieldSelectedColor = StyleGuideManager.loginTextFieldSelectedColor
    static let registerTextFieldTextColor = UIColor(withNumbersFor: 36, green: 217, blue: 255)
    static let registerPageTextColor = UIColor.darkGray
    
    //Map
    static let floatingSpaceinLabelColor = UIColor(withNumbersFor: 8, green: 203, blue: 252)
    static let floatingSpaceinNeonBackground = UIColor(withNumbersFor: 4, green: 144, blue: 237)
    static let floatingSpaceinLabelFont = UIFont(name: "Helvetica-Bold", size: 72)
    
    //login status color
    static let greenColor = UIColor(r: 0, g: 240, b: 172)
    
    
    //Fonts
    func loginFontLarge() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 30)!

    }
    
    func loginPageFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 15)!
    }
    
    func loginPageSmallFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 13)!
    }
    
    func askLocationViewFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 16)!
    }
    
    //MARK: - Forgot Password
    static let forgotPasswordTextColor = UIColor(withNumbersFor: 66, green: 80, blue: 83)
    
    func forgotPasswordPageFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 17)!
    }
    
    //MARK: - Profile
    func profileNameLabelFont() -> UIFont {
        return UIFont(name: "Helvetica", size: 20)!
    }
    
    func profileSublabelFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 16)!
    }
    
    func profileBioFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 14)!
    }
    
    func profileNotificationsFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 10)!
    }
}


