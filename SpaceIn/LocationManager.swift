//
//  LocationManager.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

enum UserLocationStatus {
    case unknown
    case authorized
    case denied
    case Other
}

class LocationManager : NSObject {

    static let sharedInstance = LocationManager()
    
    var userLocation: CLLocation? {
        didSet {
            self.stopTrackingUser()
             NotificationCenter.default.post(name: .didSetUserLocation, object: nil)
        }
    }
    
    
    func userLocationStatus() -> UserLocationStatus {
        let status = self.locationStatus()
        
        if status == .authorizedWhenInUse {
            return .authorized
        } else if status == .notDetermined {
            return .unknown
        } else if status == .denied {
            return .denied
        } else {
            return .Other
        }
    }
    
    func requestUserLocation() {
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func startTrackingUser() {
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }
    
    func latestLocation() -> CLLocation? {
        return self.lastLocation
    }
    
    fileprivate let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

}

// MARK: - CLLocationManagerDelegate
extension LocationManager : CLLocationManagerDelegate {
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("location updated")
        
        if locations.count > 0  {
            self.userLocation = locations[0]
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            self.startTrackingUser()
        } else if status == .denied {
            NotificationCenter.default.post(name: .deniedLocationPermission, object: nil)
        } else if status == .notDetermined {
            self.requestUserLocation()
        } else if status == .restricted {
            NotificationCenter.default.post(name: .restrictedLocationPermission, object: nil)
        }
    }
    
    
}


// MARK: - Private
extension LocationManager {
    fileprivate func locationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    fileprivate func stopTrackingUser() {
        self.locationManager.stopUpdatingLocation()
    }
    

}
