//
//  FirebaseAuthenticator.swift
//  SpaceIn
//
//  Created by John Nik on 11/15/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn
import GeoFire
import OneSignal

enum FirebaseReturnType {
    //Create user
    case UserAlreadyCreated
    case Success
    case NoUID
    case UserNotFound
    case weakPassword
    
    //Sign in
    case InvalidPassword
    case EmailDoesntExist
    case InvalidEmail
    
    //Default
    case Unknown
    
    case InvalidToken
    
    //Network
    case NetworkError
    case TooManyRequests
    
    //User information
    case informationNotValid
}

class FirebaseHelper {
    
    static let fireBaseBaseURL = "https://spacein-e9434.firebaseio.com/"
    static let usersBranchURL = FirebaseHelper.fireBaseBaseURL + usersBranchName
    
    // User branch
    static let usersBranchName = "users"
    static let userNameKey = "name"
    static let userEmailKey = "email"
    static let userAgeKey = "age"
    static let userLocationKey = "location"
    static let userJobKey = "job"
    static let userBioKey = "bio"
    static let userProfilePictureKey = "profilePictureURL"
    static let profilePicturesBasePath = "profilePictures"
    
    static let userLatKey  = "lat"
    static let userLonKey = "lon"
    static let userIsLogIn = "isLogIn"
    
    static let pushToken = "pushToken"
    
    class func createUser(name: String, email: String, password: String, pushToken: String?, completion: @escaping ( _ name: String, _ email: String, _ uid: String, _ pushToken: String?, _ fbReturnType: FirebaseReturnType) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
            if error != nil {
                completion("", "", "", "", FirebaseHelper.feedback(forError: error!))
                return
            } else if user?.uid != nil {
                FirebaseHelper.addUserToDatabase(user: user!, name: name, email: email, pushToken: pushToken, completion: completion)
            } else {
                completion("", "", "", "", FirebaseReturnType.NoUID)
            }
        })

        
    }
    
    class func addUserToDatabase(user: User, name: String, email: String, pushToken: String?, completion: @escaping ( _ name: String, _ email: String, _ uid: String, _ pushToken: String?, _ fbReturnType: FirebaseReturnType) -> Void) {
        
        let ref = Database.database().reference(fromURL: FirebaseHelper.fireBaseBaseURL)
        let usersReference = ref.child(FirebaseHelper.usersBranchName).child(user.uid)
        let values = [FirebaseHelper.userNameKey: name, FirebaseHelper.userEmailKey: email, FirebaseHelper.pushToken: pushToken]
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                completion("", "", "", "", FirebaseHelper.feedback(forError: err!))
                return
            } else {
                completion(name, email, user.uid, pushToken, .Success)
            }
            print("Saved user successfully into Firebase db")
        })
    }
    
    class func loginUser(email: String, password: String, completion: @escaping (_ user: User?, _ returnType: FirebaseReturnType) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                completion(nil, FirebaseHelper.feedback(forError: error!))
                return
            } else {
                completion(user!, FirebaseReturnType.Success)
            }
        })
    }
    
    class func sendResetEmailTo(email: String, completion: @escaping (_ returnType: FirebaseReturnType) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                completion(FirebaseReturnType.Success)
            } else {
                completion(FirebaseHelper.feedback(forError: error!))
            }
        }
    }
    
    private class func feedback(forError error: Error) -> FirebaseReturnType {
        var returnType = FirebaseReturnType.Unknown
        
        if let errCode = AuthErrorCode(rawValue: error._code) {
            switch errCode {
            case .invalidEmail:
                returnType = .InvalidEmail
                print("WARNING: invalid email entered")
                break
            case .networkError:
                returnType = .NetworkError
                print("WARNING: There was a nework error while executing firbase call")
                break
            case .userNotFound:
                returnType = .UserNotFound
                print("WARNING: This user was not found in the Database")
                break
            case .userTokenExpired:
                returnType = .UserNotFound
                print("WARNING: This user's local token has expired and they need to sign in again")
                break
            case .tooManyRequests:
                returnType = .TooManyRequests
                print("WARNING: We have made too many requests")
                break
            case .invalidAPIKey:
                fatalError("we must fix the API key")
                break
            case .internalError:
                print("GOOGLE INTERNAL ERROR SEND REPORT TO GOOGLE")
                print(error)
                break
            case .wrongPassword:
                returnType = .InvalidPassword
                break
            case .weakPassword:
                returnType = .weakPassword
            default:
                print("Create User Error: \(error)")
            }

        }
        
        return returnType
    }
    
    class func loggedInUser() -> User? {
        return Auth.auth().currentUser
    }
    
    class func userIsSignedIn() -> Bool {
        return loggedInUser() != nil
    }
    
    class func signOut() {
        do {
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            var values = ["isLogIn": false] as [String : AnyObject]
            let ref = Database.database().reference().child("users").child(uid)
            ref.updateChildValues(values) { (error, ref) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
            }

            try Auth.auth().signOut()
            Global.isLogIn = false
            UserDefaults.standard.set(false, forKey: "IsLogIn")
            UserDefaults.standard.setValue(nil, forKey: "CurrentUser")
            UserDefaults.standard.synchronize()
        } catch {
            print("we could not sign out")
        }
    }
    
    class func setUIDelegateTo(delegate: GIDSignInUIDelegate) {
        GIDSignIn.sharedInstance().uiDelegate = delegate
    }
    
    class func loginWithCredential(credential: AuthCredential, andUser user: GIDGoogleUser) {
        Auth.auth().signIn(with: credential, completion: { (returnedUser, error) in
            if error != nil {
                NotificationCenter.default.post(name: .DidFailLogin, object: nil)
                print("there was an error") 
            } else if returnedUser != nil {
                
                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                let userID = status.subscriptionStatus.userId
                
                FirebaseHelper.addUserToDatabase(user: returnedUser!, name: user.profile.name, email: user.profile.email, pushToken: userID, completion: { userName, userEmail, userID, pushToken, returnType in
                    if returnType == .Success {
                        
                        SpaceInUser.current = SpaceInUser(name: userName, email: userEmail, uid: userID)
                        SpaceInUser.current?.loadInformationFromServer()
                        
                        var profileChange = ProfileChanges()
                        profileChange.isLogIn = true
                        
                        guard let uid = Auth.auth().currentUser?.uid else {
                            return
                        }
                        
                        let geoFireRef = Database.database().reference().child("users").child(uid).child("user_location")
                        let geoFire = GeoFire(firebaseRef: geoFireRef)
                        
                        geoFire?.setLocation(Global.currentUserLocation, forKey: uid)
                        
                        
                        FirebaseHelper.makeProfileChanges(changes: profileChange, for: (SpaceInUser.current?.uid)!, completion: { (returnType) in
                            if returnType == FirebaseReturnType.Success {
                                
                                print("success to save user location")
                                Global.isLogIn = true
                                UserDefaults.standard.set(true, forKey: "IsLogIn")
                                UserDefaults.standard.synchronize()
                                
                            } else {
                                print("Fail to save user location")
                            }
                        }) { (notUsed, AlsoNotUsedString) in
                            
                        }
                        
                        SpaceInUser.current?.loadInformationFromServer()
                        
                    } else {
                        NotificationCenter.default.post(name: .DidFailLogin, object: nil)
                    }
                    print("we should have updated the database with a user")
                })
            } else {
                NotificationCenter.default.post(name: .DidFailLogin, object: nil)
            }
        })
    }
    
    
    class func makeProfileChanges(changes: ProfileChanges, for userID: String, completion: @escaping (FirebaseReturnType) -> (), imageChangeCompletion: @escaping ((Bool, String?) -> ())) {
        if let newProfilePic = changes.image {
            FirebaseHelper.setNewProfileImage(newProfilePic, for: userID, completion: imageChangeCompletion)
        }
        
        guard let values = valuesForChanges(changes: changes) else {
            completion(FirebaseReturnType.Success) // successfull if there are not any non image changes
            return
        }
        
        let usersReference = FirebaseHelper.profileReference().child(userID)
        
        usersReference.updateChildValues(values) { (error, returnedRef) in
            if let error = error {
                completion(feedback(forError: error))
            } else {
                completion(FirebaseReturnType.Success)
            }
        }
    }
    
    
    class func fetchInfoForUserID(userID: String, completion: @escaping (FirebaseReturnType, ProfileChanges?)->()) {
        let ref = FirebaseHelper.profileReference().child(userID)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value else {
                completion(FirebaseReturnType.UserNotFound, nil)
                return
            }
            
            guard let dictionary = value as? NSDictionary else {
                completion(FirebaseReturnType.informationNotValid, nil)
                return
            }
            
            completion(FirebaseReturnType.Success, FirebaseHelper.profileChanges(from: dictionary))
        })
    }
}


//MARK: - Profile Branch
extension FirebaseHelper {
    fileprivate class func profileReference() -> DatabaseReference {
        return Database.database().reference(fromURL: FirebaseHelper.fireBaseBaseURL).child(FirebaseHelper.usersBranchName)
    }
    
    fileprivate class func profileChanges(from dict: NSDictionary) -> ProfileChanges? {
        let name = dict[FirebaseHelper.userNameKey] as? String
        let email = dict[FirebaseHelper.userEmailKey] as? String
        let age = dict[FirebaseHelper.userAgeKey] as? Int
        let location = dict[FirebaseHelper.userLocationKey] as? String
        let job = dict[FirebaseHelper.userJobKey] as? String
        let bio = dict[FirebaseHelper.userBioKey] as? String
        let imageURL = dict[FirebaseHelper.userProfilePictureKey] as? String
        
        let lat = dict[FirebaseHelper.userLatKey] as? Double
        let lon = dict[FirebaseHelper.userLonKey] as? Double
        let isLogIn = dict[FirebaseHelper.userIsLogIn] as? Bool
        let pushToken = dict[FirebaseHelper.pushToken] as? String
        
        let profileChanges = ProfileChanges(name: name, image: nil, age: age, location: location, job: job, bio: bio, imageURL: imageURL, email: email, lat: lat, lon: lon, isLogIn: isLogIn, pushToken: pushToken)
        
        return profileChanges
    }
}


//MARK: - Profile Changes

extension FirebaseHelper {
    fileprivate class func valuesForChanges(changes: ProfileChanges) -> [String: Any]? {
        guard !changes.isEmpty() else {
            return nil
        }
        
        var valueDictionary = [String: Any]()
        
        if let name = changes.name {
            valueDictionary[FirebaseHelper.userNameKey] = name
        }
        
        if let age = changes.age {
            valueDictionary[userAgeKey] = age
        }
        
        if let location = changes.location {
            valueDictionary[userLocationKey] = location
        }
        
        if let job = changes.job {
            valueDictionary[userJobKey] = job
        }
        
        if let bio = changes.bio {
            valueDictionary[userBioKey] = bio
        }
        
        if let imageURL = changes.imageURL {
            valueDictionary[userProfilePictureKey] = imageURL
        }
        
        if let lat = changes.lat {
            valueDictionary[userLatKey] = lat
        }
        
        if let lon = changes.lon {
            valueDictionary[userLonKey] = lon
        }
        
        if let isLogIn = changes.isLogIn {
            valueDictionary[userIsLogIn] = isLogIn
        }
        
        if valueDictionary.isEmpty {
            return nil
        } else {
            return valueDictionary
        }
    }
}


//MARK: - Image Changes

extension FirebaseHelper {
    fileprivate static func setNewProfileImage(_ image: UIImage, for userID: String, completion: @escaping(Bool, String?) ->()) {
        guard FirebaseHelper.userIsSignedIn() else {
            completion(false, "You must be signed in to change a picture")
            return // cannot post if user is not signed in
        }
        
        guard let imageToPost = image.normalizedImage() else {
            completion(false, "Image could not be normalized")
            return
        }
        
        guard let data = UIImageJPEGRepresentation(imageToPost, 1.0) else {
            completion(false, "We could not proccess the image")
            return
        }
        
        let ref = storageRef().child(FirebaseHelper.profilePicturesBasePath).child(userID)
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        ref.putData(data, metadata: uploadMetaData) { (downloadMeta, error) in
            if let error = error {
                completion(false, error.localizedDescription)
            } else if let downloadMeta = downloadMeta {
                if let downLoadURL = downloadMeta.downloadURL() {
                    changeProfilePictureURl(url: downLoadURL.absoluteString, uid: userID, completion: completion)
                } else {
                    completion(false, "something went wrong. there is download meta data but there is no download url")
                }
            } else {
                completion(false, "Something else went wrong. There is no error and there is no download Meta data")
            }
        }
    }
    
    private static func changeProfilePictureURl(url: String, uid: String, completion: @escaping(Bool, String)->()) {
        let changes = ProfileChanges(name: nil, image: nil, age: nil, location: nil, job: nil, bio: nil, imageURL: url, email: nil, lat: nil, lon: nil, isLogIn: nil, pushToken: nil)
        
        FirebaseHelper.makeProfileChanges(changes: changes, for: uid, completion: { (returnType) in
            if returnType == FirebaseReturnType.Success {
                completion(true, url)
            } else {
                completion(false, "There was an issue saving the image url")
            }
        }) { (notUsed, AlsoNotUsedString) in
            
        }
    }
    
    private static func storageRef() -> StorageReference {
        return Storage.storage().reference()
    }
    
    
    private func setImageURL(url: String, uid: String) {
        
    }
}




