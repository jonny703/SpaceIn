//
//  SpaceUserAnnotation.swift
//  SpaceIn
//
//  Created by John Nik on 11/15/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import MapKit

class SpaceUserAnnotation: MKPointAnnotation {
    let name: String
    let uid: String
    let user: SpaceUser
    
    init(withUser user: SpaceUser, coordinate: CLLocationCoordinate2D) {
        self.name = user.name!
        self.uid = user.userId!
        self.user = user
        super.init()
        self.coordinate = coordinate
    }
}
