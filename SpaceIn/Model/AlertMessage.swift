//
//  AlertMessage.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation

enum AlertMessages: String {
    case defaultTitle = "Sorry"
    case defaultButtontitle = "Retry"
    
    case invalidEmailTitle = "Invalid Email"
    case invalidEmailSubTitle = "That email is invalid"
    
    case invalidPasswordSubtitle = "That password is wrong"
    
    case weakPasswordTitle = "Password too weak"
    case weakPasswordSubtitle = "Please make sure that the password is not too easy to guess"
    
    case passwordTooShortSubtitle = "This password is too short"
    case passwordTooLongSubtitle = "This password is too long"
    
    case mismatchPasswordTitle = "Password's Don't Match"
    case mismatchPasswordSubtitle = "The passwords you have set are not the same"
    
    case invalidNameTitle = "Please make sure to type a name longer than 2 characters"
    
    case unknownErrorTitle = "An Unknown Error Occured"
    case unknownErrorSubtitle = "Please try again later"
    
    case userAlreadyExistsTitle = "Error"
    case userAlreadyExistsSubtitle = "That email address is already in use"
    
    case userNotFoundTitle = "User Not Found"
    case userNotFoundSubtitle = "This account does not exist"
    
    case networkIssueTitle = "Network Error"
    case networkIssueSubtitle = "Unable to connect to the internet"
    
    case failedSocialLoginSubtitle = "Something went wrong with Google login. Please try again later"

    case failedAuthTitle = "Authentication Error"
    case failedAuthSubTitle = "Oops, something went wrong with the authentication. Please try again later"
    
    case emailSentTitle = "Email Sent"
    case emailSentSubtitle = "An email with further instructions has been sent"
    case emailSentButtonTitle = "OK"
    
    case locationPermissionResetTitle = "Sorry, but you need to allow us to access your location to use this feature."
    case locationPermissionResetSubTitle = "Go to settings to fix this!"
    case okayButtonTitle = "Okay"
    
    case failedToPostToServerTitle = "Oops, looks like something is going on with our servers"
    case failedToPostToServerSubTitle = "There might be many people trying to access our servers right now, this issue may be fixed momentarily"
    
    case failedInternetTitle = "Oops, looks like something is wrong with your Internet"
    case failedToPostInternetSubtitle = "There might be something wrong with your Internet connection or our servers"
    
    case failedToSignOutTitle = "Oops, there was an issue signing out"
    case failedToSignOutSubTitle = "Would you like to try again"


}

class AlertMessage {
    var alertTitle: String
    var alertSubtitle: String?
    var actionButton1Title: String
    var actionButton2title: String?
    
    public init (title: String, subtitle: String?, actionButtontitle: String, secondButtonTitle: String?) {
        self.alertTitle = title
        self.alertSubtitle = subtitle
        self.actionButton1Title = actionButtontitle
        self.actionButton2title = secondButtonTitle
    }
    
    class func invalidEmail() -> AlertMessage {
        return AlertMessage(title: AlertMessages.defaultTitle.rawValue, subtitle: AlertMessages.invalidEmailSubTitle.rawValue, actionButtontitle: AlertMessages.defaultButtontitle.rawValue, secondButtonTitle: "")
    }
    
    class func invalidPassword() -> AlertMessage {
        return AlertMessage(title: AlertMessages.defaultTitle.rawValue, subtitle: AlertMessages.invalidPasswordSubtitle.rawValue, actionButtontitle: AlertMessages.defaultButtontitle.rawValue, secondButtonTitle: "")
    }
    
    class func passwordTooShort() -> AlertMessage {
        return AlertMessage(title: AlertMessages.defaultTitle.rawValue, subtitle: AlertMessages.passwordTooShortSubtitle.rawValue, actionButtontitle: "Ok", secondButtonTitle: "")
    }
    
    class func passwordTooLong() -> AlertMessage {
        return AlertMessage(title: AlertMessages.defaultTitle.rawValue, subtitle: AlertMessages.passwordTooLongSubtitle.rawValue, actionButtontitle: "Ok", secondButtonTitle: "")
    }
    
    
    
    class func passwordsDontMatch() -> AlertMessage {
        return AlertMessage(title: AlertMessages.defaultTitle.rawValue, subtitle: AlertMessages.mismatchPasswordSubtitle.rawValue, actionButtontitle: "Ok", secondButtonTitle: "")
    }
    
    class func invalidName() -> AlertMessage {
        return AlertMessage(title: AlertMessages.invalidNameTitle.rawValue, subtitle: "", actionButtontitle: "Ok", secondButtonTitle: "")
    }
    
    class func passwordResetSent() -> AlertMessage {
        return AlertMessage(title: AlertMessages.emailSentTitle.rawValue, subtitle: AlertMessages.emailSentSubtitle.rawValue, actionButtontitle: AlertMessages.emailSentButtonTitle.rawValue, secondButtonTitle: "")
    }
    
    class func alertMessageForFireBaseReturnType(returnType: FirebaseReturnType) -> AlertMessage {
        var titleMessage = AlertMessages.unknownErrorTitle.rawValue
        var subtitleMessage = AlertMessages.unknownErrorSubtitle.rawValue
        let alertButtonMessageOne = AlertMessages.defaultButtontitle.rawValue
        
        switch returnType {
        case .InvalidEmail:
            titleMessage = AlertMessages.invalidEmailTitle.rawValue
            subtitleMessage = AlertMessages.invalidEmailSubTitle.rawValue
            break
        case .InvalidPassword:
            titleMessage = AlertMessages.defaultTitle.rawValue
            subtitleMessage = AlertMessages.invalidPasswordSubtitle.rawValue
            break
        case .weakPassword:
            titleMessage = AlertMessages.weakPasswordTitle.rawValue
            subtitleMessage = AlertMessages.weakPasswordTitle.rawValue
        case .UserAlreadyCreated:
            titleMessage = AlertMessages.defaultTitle.rawValue
            subtitleMessage = AlertMessages.userAlreadyExistsSubtitle.rawValue
            break
        case .EmailDoesntExist:
            titleMessage = AlertMessages.invalidEmailTitle.rawValue
            subtitleMessage = AlertMessages.invalidEmailSubTitle.rawValue
            break
        case .NoUID:
            break
        case .UserNotFound:
            titleMessage = AlertMessages.defaultTitle.rawValue
            subtitleMessage = AlertMessages.userNotFoundSubtitle.rawValue
            break
        case .NetworkError:
            titleMessage = AlertMessages.defaultTitle.rawValue
            subtitleMessage = AlertMessages.networkIssueSubtitle.rawValue
            break
        default:
            break
        }
        
        return AlertMessage(title: titleMessage, subtitle: subtitleMessage, actionButtontitle: alertButtonMessageOne, secondButtonTitle: nil)
    }
    
    class func failedSocialLogin() -> AlertMessage {
        return AlertMessage(title: AlertMessages.defaultTitle.rawValue, subtitle: AlertMessages.failedSocialLoginSubtitle.rawValue, actionButtontitle: "Ok", secondButtonTitle: nil)
    }
    
    class func failedAuth() -> AlertMessage {
        return AlertMessage(title: AlertMessages.failedAuthTitle.rawValue, subtitle: AlertMessages.failedAuthSubTitle.rawValue, actionButtontitle: "Ok", secondButtonTitle: nil)
    }
    
    class func serverIssueSavingProfile() -> AlertMessage {
        return AlertMessage(title: AlertMessages.failedToPostToServerTitle.rawValue, subtitle: AlertMessages.failedToPostToServerSubTitle.rawValue, actionButtontitle: "Ok, Maybe Later", secondButtonTitle: "Try Again")
    }
    
    class func issueLoggingOut() -> AlertMessage {
        return AlertMessage(title: AlertMessages.failedToSignOutTitle.rawValue, subtitle: AlertMessages.failedToSignOutSubTitle.rawValue, actionButtontitle: "Yes", secondButtonTitle: "No")
    }
    
    class func networkIssueSavingProfile() -> AlertMessage {
        return AlertMessage(title: AlertMessages.failedInternetTitle.rawValue, subtitle: AlertMessages.failedToPostInternetSubtitle.rawValue, actionButtontitle: "Ok, Maybe Later", secondButtonTitle: "Try Again")
    }
}


