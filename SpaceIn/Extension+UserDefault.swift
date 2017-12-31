//
//  Extension+UserDefault.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
extension UserDefaults {
    
    
    enum UserDefaultsKeys: String {
        case isLoggedIn
        case timeStampLastViewedMessage
    }
    
    //MARK: check login
    
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    //MARK: save user full name
    
}
