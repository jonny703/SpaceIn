//
//  ReachibilityManager.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation

class ReachabilityManager {
    static let shared = ReachabilityManager()
    fileprivate var reachibility = Reachability()
    
    public fileprivate(set) var internetIsUp = true
    
    static func setup() {
        let _ = ReachabilityManager.shared
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachibility)
        do{
            try reachibility?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
}


extension ReachabilityManager {
    @objc fileprivate func reachabilityChanged(note: Notification) {
        guard let reachability = note.object as? Reachability else {
            return
        }
        
        internetIsUp = reachability.isReachable
    }
}
