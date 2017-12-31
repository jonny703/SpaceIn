//
//  User.swift
//  SpaceIn
//
//  Created by John Nik on 11/15/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit

class SpaceUser: NSObject {
    
    var userId: String?
    var name: String?
    var profilePictureURL: String?
    var email: String?
    var location: String?
    var bio: String?
    var age: NSNumber?
    var job: String?
    var isLogIn: NSNumber?
    var user_location: [String: [String: Any]]?
    var postCount: NSNumber?
    var pushToken: String?
}
