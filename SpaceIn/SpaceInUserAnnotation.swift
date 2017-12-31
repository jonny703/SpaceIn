//
//  SpaceinUserAnnotation
//  SpaceIn
//
//  Created by John Nik on 11/15/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import MapKit

class SpaceinUserAnnotation: MKPointAnnotation {
    let name: String
    let uid: String
    let user: SpaceInUser
    
    init(withUser user: SpaceInUser, coordinate: CLLocationCoordinate2D) {
        self.name = user.name
        self.uid = user.uid
        self.user = user
        super.init()
        self.coordinate = coordinate
    }
}
