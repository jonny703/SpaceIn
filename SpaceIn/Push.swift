//
//  File.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import Firebase

class Push: NSObject {
    
    var pushId: String?
    var fromId: String?
    var toId: String?
    var pushKey: NSNumber?
    var timestamp: NSNumber?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        pushKey = dictionary["pushKey"] as? NSNumber
        timestamp = dictionary["timestamp"] as? NSNumber
    }
    
}

enum PushAction: String {
    case invitation = "invitation"
    case accept = "accept"
    case decline = "decline"
}
