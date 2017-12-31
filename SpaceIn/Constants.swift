//
//  Constants.swift
//  SpaceIn
//
//  Created by John Nik on 11/15/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import UIKit

let DEVICE_WIDTH = UIScreen.main.bounds.size.width
let DEVICE_HEIGHT = UIScreen.main.bounds.size.height


extension Notification.Name {
    
    static let DidSetCurrentUser = Notification.Name("did-set-current-user")
    static let DidSetCurrentUserProfilePicture = Notification.Name("did-set-current-user-profile-picture")
    static let DidUpdateCurrentUser = Notification.Name("did-update-current-user")
    static let DidFailGoogleLogin = Notification.Name("did-fail-google-login")
    static let DidFailAuthentication = Notification.Name("did-fail-auth")
    static let DidFailLogin = Notification.Name("did-fail-login-firebase")
    static let didSetUserLocation = Notification.Name("did-set-user-location")
    static let deniedLocationPermission = Notification.Name("did-deny-user-location")
    static let restrictedLocationPermission = Notification.Name("restricted-user-location")
    
    static let NotLogInMessage = Notification.Name("not-login-user")
    static let FetchUsersWhenLogOut = Notification.Name("fetch-users-logout")
    static let FetchUsers = Notification.Name("fetch-users")
    
    static let ShowAcceptController = Notification.Name("show-accept-controller")
    static let SetupOneSignal = Notification.Name("setup-onesignal")
    static let ResetBadgeLabel = Notification.Name("reset-badge-label")
    static let ResetBadgeLabelWhenRemovedMessage = Notification.Name("reset-badge-label-when-remove-message")
    
    static let setPushLabelNewMessages = Notification.Name("set-push-label-new-messages")
    static let setPushLabelReadMessages = Notification.Name("set-push-label-read-messages")
    
}

enum SpaceinCopy: String {
    case forgotPasswordTitle = "Trouble logging in?"
    case forgotPasswordSubtitle = "Enter your email and we'll send you a link to get back into your account."
    case forgotPasswordPageButtonCopy = "Send login link"
    case spaceInFloatingLabelText = "Spacein"
    case locationPermissionViewBottomText = "Please enable notifications and grant us permission to access your location so you may have the best experience possible"
    
}

enum UserDefaultKeys : String {
    case hasSeenTutorial = "Has seen tutorial" // we can never change this
    case lastKnownSpaceInLattitude = "lastKnownLattitude" // we can never change this
    case lastKnownSpaceInLongitude = "lastKnownLongitude" // we can never change this
    case hasSeenMapBefore = "hasSeenMapBefore" // we can never change this
}
