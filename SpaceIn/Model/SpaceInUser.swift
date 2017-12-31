//
//  SpaceInUser.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import SDWebImage

struct ProfileChanges {
    var name: String?
    var image: UIImage?
    var age: Int?
    var location: String?
    var job: String?
    var bio: String?
    var imageURL: String?
    var email: String?
    
    var lat: Double?
    var lon: Double?
    var isLogIn: Bool?
    var pushToken: String?
    
    func isEmpty() -> Bool {
        if name != nil {
            return false
        }
        
        if image != nil {
            return false
        }
        
        if age != nil {
            return false
        }
        
        if location != nil {
            return false
        }
        
        if job != nil {
            return false
        }
        
        if bio != nil {
            return false
        }
        
        if imageURL != nil {
            return false
        }
        
        if lat != nil {
            return false
        }
        
        if lon != nil {
            return false
        }
        
        if isLogIn != nil {
            return false
        }
        
        if pushToken != nil {
            return false
        }
        
        return true
    }
}

class SpaceInUser: NSObject {
    public static var current : SpaceInUser? {
        didSet {
            SpaceInUser.saveSettingsToUserDefaults()
            SpaceInUser.didSetCurrentUser()
        }
    }
    
    var name: String
    var email: String
    var uid: String
    
    var bio: String?
    var age: Int?
    var job: String?
    var location: String?
    var image: UIImage?
    var imageURL: String? {
        didSet {
            if oldValue != imageURL {
                if let newURL = imageURL {
                    if newURL.isValidString() {
                        updateProfileImage()
                    }
                }
            }
        }
    }
    
    var lat: Double?
    var lon: Double?
    var isLogIn: Bool?
    var pushToken: String?
    
    fileprivate var previousProfileImage: UIImage?
    fileprivate var previousProfileImageURL: String?

    
    fileprivate var coordinate: CLLocationCoordinate2D? {
        didSet {
            SpaceInUser.saveLocationToUserDefaults(shouldSynchronize: true)
        }
    }
    
    public init (name: String, email: String, uid: String) {
        self.name = name
        self.email = email
        self.uid = uid
        super.init()
    }
    
    convenience init (fireBaseUser: User, coordinate: CLLocationCoordinate2D?) {
        let name = fireBaseUser.displayName ?? ""
        let email = fireBaseUser.email ?? ""
        let uid = fireBaseUser.uid
        
        self.init(name: name, email: email, uid: uid)
        
        guard let coordinate = coordinate else { return }
        
        movedToCoordinate(coordinate: coordinate)
    }
    
    //MARK: - User default copy
    
    static let loggedInUserNameString = "UserName"
    static let loggedInUserEmailString = "UserEmail"
    static let loggedInUserUIDString = "UserUID"
    static let loggedInUserAgeInt = "UserAGE"
    static let loggedInUserLocationString = "UserLocationLiving"
    static let loggedInUserJobString = "UserJob"
    static let loggedInUserBioString = "UserJob"
    static let loggedInUserCoordinateLatString = "UserCoordinateLat"
    static let loggedInUserCoordinateLongString = "UserCoordinateLong"
}


//MARK: - API

extension SpaceInUser {
    // we load information from user defaults. Then if we have a valid
    static func initializeCurrentUser() {
        guard SpaceInUser.current == nil else {
            return  // we don't overwrite the current user with the info from defaults. we only write to defaults
        }
        
        let defaults = UserDefaults.standard
        
        let name = defaults.value(forKey: SpaceInUser.loggedInUserNameString) as? String ?? ""
        
        let email = defaults.value(forKey: SpaceInUser.loggedInUserEmailString) as? String ?? ""
        
        let uid = defaults.value(forKey: SpaceInUser.loggedInUserUIDString) as? String ?? ""
        
        SpaceInUser.current = SpaceInUser(name: name, email: email, uid: uid)
        
        if let currentUser = SpaceInUser.current {
            if let age = defaults.value(forKey: SpaceInUser.loggedInUserAgeInt) as? Int {
                currentUser.age = age
            }
            
            if let location = defaults.value(forKey: SpaceInUser.loggedInUserLocationString) as? String {
                currentUser.location = location
            }
            
            if let job = defaults.value(forKey: SpaceInUser.loggedInUserJobString) as? String {
                currentUser.job = job
            }
            
            if let bio = defaults.value(forKey: SpaceInUser.loggedInUserBioString) as? String {
                currentUser.bio = bio
            }
        }
        
        if let userLat = defaults.value(forKey: SpaceInUser.loggedInUserCoordinateLatString) as? Double {
            if let userLong = defaults.value(forKey: SpaceInUser.loggedInUserCoordinateLongString) as? Double {
                 SpaceInUser.current!.movedToCoordinate(coordinate: CLLocationCoordinate2D(latitude: userLat, longitude: userLong))
            }
        }
        
        SpaceInUser.current?.loadInformationFromServer()
       
    }
    
    
    func movedToCoordinate(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func getCoordinate() -> CLLocationCoordinate2D? {
        return self.coordinate
    }
    
    static func logOut() {
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: SpaceInUser.loggedInUserNameString)
        defaults.removeObject(forKey: SpaceInUser.loggedInUserEmailString)
        defaults.removeObject(forKey: SpaceInUser.loggedInUserUIDString)
        
        let existingCoordinate = SpaceInUser.current?.coordinate
        SpaceInUser.current = SpaceInUser(name: "", email: "", uid: "")
        
        if let coordinate = existingCoordinate {
            SpaceInUser.current?.movedToCoordinate(coordinate: coordinate)
        }
        
        postProfileImageChangedNotification()
    }
    
    
    static func userIsLoggedIn() -> Bool {
        guard SpaceInUser.current != nil else {
            return false
        }
        
        return SpaceInUser.current!.uid.characters.count > 0
    }
    
    func madeChanges(changes: ProfileChanges, completion: @escaping (Bool, FirebaseReturnType?) -> ()) {
        guard !changes.isEmpty() else {
            completion(true, nil)
            return
        }
        
        makeChanges(changes: changes, completion: completion)
    }
}


//MARK: - LoadingState
extension SpaceInUser {
    func loadInformationFromServer() {
        guard self.uid.isValidString() else {
            return
        }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            guard self != nil else {
                return
            }
            
            FirebaseHelper.fetchInfoForUserID(userID: self!.uid, completion: { (firReturnType, changes) in
                guard let strongSelf = self else {
                    return
                }
                
                if firReturnType == FirebaseReturnType.Success && changes != nil {
                    strongSelf.loadChangesFromServer(changes: changes!)
                } else {
                    strongSelf.failedToLoadInfoFromServer()
                }
            })
        }
    }
    
    private func loadChangesFromServer(changes: ProfileChanges?) {
        var didLoadNewChanges = false
        
        if let name = changes?.name {
            self.name = name
            didLoadNewChanges = true
        }
        
        if let age = changes?.age {
            self.age = age
            didLoadNewChanges = true
        }
        
        if let location = changes?.location {
            self.location = location
            didLoadNewChanges = true
        }
        
        if let job = changes?.job {
            self.job = job
            didLoadNewChanges = true
        }
        
        if let bio = changes?.bio {
            self.bio = bio
            didLoadNewChanges = true
        }
        
        // if we have an image we don't want to set the image url
        if let image = changes?.image {
            self.image = image
        } else if let imageURL = changes?.imageURL {
            self.imageURL = imageURL
        }
        
        if let email = changes?.email {
            self.email = email
            didLoadNewChanges = true
        }
        
        if didLoadNewChanges {
            didLoadChanges()
        }
    }
    
    private func failedToLoadInfoFromServer() {
        
    }
    
    private func didLoadChanges() {
        if self == SpaceInUser.current {
            SpaceInUser.didSetCurrentUser()
        }
    }
}


//MARK: - Image
extension SpaceInUser {
    fileprivate func updateProfileImage() {
        guard let urlForProfilePicture = imageURL else {
            return
        }
        
        guard let url = URL(string: urlForProfilePicture) else {
            return
        }
        
        
        
        SDWebImageManager.shared().downloadImage(with: url, options: SDWebImageOptions(rawValue: 0), progress: { (one, two) in
            
        }) { [weak self] (image, error, cacheType, finished, url) in
            if let image = image {
                self?.image = image
                if self == SpaceInUser.current {
                    SpaceInUser.postProfileImageChangedNotification()
                }
                
            }
        }
    }
}


//MARK: - Setter

extension SpaceInUser {
    fileprivate class func didSetCurrentUser() {
        if SpaceInUser.current != nil {
            NotificationCenter.default.post(name: .DidSetCurrentUser, object: nil)
        }
    }
    
    fileprivate static func saveSettingsToUserDefaults() {
        guard SpaceInUser.current != nil else {
            return // we only save the current user to userDefaults
        }
        
        let defaults = UserDefaults.standard
        
        defaults.set(SpaceInUser.current!.uid, forKey: SpaceInUser.loggedInUserUIDString)
        defaults.set(SpaceInUser.current!.name, forKey: SpaceInUser.loggedInUserNameString)
        defaults.set(SpaceInUser.current!.uid, forKey: SpaceInUser.loggedInUserEmailString)
        
        SpaceInUser.saveLocationToUserDefaults(shouldSynchronize: false)
        defaults.synchronize()
    }
    
    fileprivate static func saveLocationToUserDefaults(shouldSynchronize: Bool) {
        if let coordinate = SpaceInUser.current?.coordinate {
            let defaults = UserDefaults.standard
            let lat = coordinate.latitude
            let long = coordinate.longitude
            defaults.set(lat, forKey: SpaceInUser.loggedInUserCoordinateLatString)
            defaults.set(long, forKey: SpaceInUser.loggedInUserCoordinateLongString)
            
            if shouldSynchronize {
                defaults.synchronize()
            }
        }
    }
}


//MARK: - Profile Changes

extension SpaceInUser {
    fileprivate func makeChanges(changes: ProfileChanges, completion: @escaping (Bool, FirebaseReturnType?) -> ()) {
        if let changedImaged = changes.image {
            previousProfileImage = image
            previousProfileImageURL = imageURL
            image = changedImaged
            if self == SpaceInUser.current {
                SpaceInUser.postProfileImageChangedNotification()
            }
        }
        
        FirebaseHelper.makeProfileChanges(changes: changes, for: uid, completion: { [weak self] (returnType) in
            if returnType == FirebaseReturnType.Success {
                self?.commit(name: changes.name, age: changes.age, location: changes.location, job: changes.job, bio: changes.bio)
                completion(true, nil)
            } else {
                completion(false, returnType)
            }
        }, imageChangeCompletion: { [weak self] success, urlString in
            if changes.image != nil {
                if success {
                    self?.imageURL = urlString
                    self?.previousProfileImage = nil
                } else {
                    print(urlString ?? "no  message")
                    self?.failedToChangeProfilePciture()
                }
            }
        })
    }
    
    private static func didUpdateCurrentUser() {
        if SpaceInUser.current != nil {
            NotificationCenter.default.post(name: .DidUpdateCurrentUser, object: nil)
        }
    }
    
    private func commit(name: String?, age: Int?, location: String?, job: String?, bio: String?) {
        var didChange = false
        
        if let newName = name {
            self.name = newName
            didChange = true
        }
        
        if let newAge = age {
            self.age = newAge
            didChange = true
        }
        
        if let newLocation = location {
            self.location = newLocation
            didChange = true
        }
        
        if let newJob = job {
            self.job = newJob
            didChange = true
        }
        
        if let newBio = bio {
            self.bio = newBio
            didChange = true
        }
        
        if didChange && self == SpaceInUser.current {
            SpaceInUser.didUpdateCurrentUser()
        }
    }
    
    fileprivate static func postProfileImageChangedNotification() {
        NotificationCenter.default.post(name: .DidSetCurrentUserProfilePicture, object: nil)
    }
    
    private func failedToChangeProfilePciture() {
        image = previousProfileImage ?? nil
        previousProfileImage = nil
        
        imageURL = previousProfileImageURL ?? nil
        previousProfileImageURL = nil
        
        SpaceInUser.postProfileImageChangedNotification()
    }
}
