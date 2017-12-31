//
//  AssetManager.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import UIKit

enum AssetName: String {
    case logoWhite = "logoWhite"
    case logoColored = "logoColored"
    case loginBackground = "loginBackground"
    case signUpButtonGradient = "gradientGreen"
    case transparentPin = "mapProfile"
    case spaceinGradient = "gradient"
    case brokenPin = "brokenGPS"
    case greenCircle = "greenCircle"
    case threeDCircle = "3dglasses"
    case locationIcon = "locationIcon"
    case notification = "notification"
    case zoomIn = "zoomIn"
    case zoomOut = "zooomOut"
    case profilePlaceholder = "profilePlaceHolder"
    case dismissButton = "dismissButton"
    case settingsButton = "settingsButton"
    case rickySquare = "rickySquare"
    case profileLocation = "profileLocation"
    case jobIcon = "jobIcon"
    case locationdot = "locationdot"
    case compass = "compass"
    case mapProfileIcon = "mapProfileIcon"
    case backButton = "backbutton"
    case plusButton = "plusButton"
    case sendButton = "sendButton"
    case playButton = "playbutton_image"
    case dismissX = "dismissX"
    case statusIcon = "statusIcon"
    case intro1 = "intro1"
    case intro2 = "intro2"
    case intro3 = "intro3"
    case intro4 = "intro4"
    
}

class AssetManager {
    static let sharedInstance = AssetManager()
    
    static var assetDict = [String : UIImage]()
    
    class func imageForAssetName(name: AssetName) -> UIImage {
        let image = assetDict[name.rawValue] ?? UIImage(named: name.rawValue)
        assetDict[name.rawValue] = image
        return image!
    }
    
}
