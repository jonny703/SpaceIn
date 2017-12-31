//
//  MapViewController.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import QuartzCore
import Shimmer
import Firebase
import GeoFire


//MARK: - Lifecycle
class MapViewController: UIViewController {
    //Public
    
    var users = [SpaceUser]()
    var spaceUser: SpaceUser?
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    var updatingLocationTimer = Timer()
    
    let mapView = MapView(frame: CGRect.zero)

    //Class level variables
    static let defaultLocation =  CLLocation(latitude: 41.8902,longitude:  12.4922)
    static let zoomLevelForShowingSpaceinView: CLLocationDistance =  MapView.zoomedOutAltitiude - 15000000
    static let spaceinViewPadding: CGFloat = 40
    static let buttonwidthHeights: CGFloat = 55
    static let buttonBottomPadding:CGFloat = 45
    static let buttonPadding:CGFloat = 20
    
    //Views
    fileprivate let logoView = UILabel(asConstrainable: true, frame: CGRect.zero)
    fileprivate let notificationsButton = RoundedButton(filledIn: false, color: UIColor.white)
    fileprivate let profileContainerButton = RoundedButton(filledIn: false, color: UIColor.white)
    fileprivate let profileButton = RoundedButton(filledIn: false, color: UIColor.clear) //for profile pictures the padding between the border and the image isn't happening so we have to wrap it in a circular view
    fileprivate let locateMeButton = UIButton(type: .custom)
    fileprivate let logoContainerView = FBShimmeringView(frame: CGRect.zero)
    fileprivate var loginRegisterVC: LoginRegisterVC?

    //Vars
    fileprivate var currentLocation : CLLocation? = MapViewController.defaultLocation
    fileprivate var zoomType: MapViewZoomType?
    fileprivate var didSetupInitialMap = false
    fileprivate var didConstrain = false
    fileprivate var viewHasAppeared = false
    
    var pushCount = 0
    var totalPushCount = 0
    var newMessageCount = 0
    
    let pushLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .white
//        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .center
        label.backgroundColor = .red
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    //Lifecycle
    convenience init(startingLocation: CLLocation, zoomType: MapViewZoomType) {
        self.init(nibName: nil, bundle: nil)
        currentLocation = startingLocation
        self.zoomType = zoomType

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationObservers()
        addNotificationObserversWithFetch()
        
        addPushNotificationObserver()
        
        UIApplication.shared.statusBarStyle = .lightContent
        mapView.mapViewDelagate = self
        mapView.mapViewController = self
        
        
        
//        mapView.isUserInteractionEnabled = true
        addViews()
        
        Global.currentCenterLocation = Global.currentUserLocation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        constrain()
        setupInitialMapViewStateIfNeccessary()
        mapView.showsUserLocation = false
        mapView.userLocation.title = nil
        fetchUsers()
        
        handleUpdatiingLocationTimer()
        
        setPushLabel()
//        self.checkPushExist()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updatingLocationTimer.invalidate()
    }
    
    deinit {
        removePushNotificationObserver()
    }
    
    private func addPushNotificationObserver() {
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(showAcceptControllerFromMapVC(notification:)), name: .ShowAcceptController, object: nil)
//        nc.addObserver(self, selector: #selector(resetPushLabelWithReadMessage(notification:)), name: .ResetBadgeLabel, object: nil)
//        nc.addObserver(self, selector: #selector(resetPushLabelWhenRemovedMessage(notification:)), name: .ResetBadgeLabelWhenRemovedMessage, object: nil)
        
        nc.addObserver(self, selector: #selector(setPlusPushCountForNewMessage(notification:)), name: .setPushLabelNewMessages, object: nil)
        nc.addObserver(self, selector: #selector(setReadPushCountForNewMessage(notification:)), name: .setPushLabelReadMessages, object: nil)
        
    }
    
    private func removePushNotificationObserver() {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: .ShowAcceptController, object: nil)
//        nc.removeObserver(self, name: .ResetBadgeLabel, object: nil)
//        nc.removeObserver(self, name: .ResetBadgeLabelWhenRemovedMessage, object: nil)
        
        nc.removeObserver(self, name: .setPushLabelNewMessages, object: nil)
        nc.removeObserver(self, name: .setPushLabelReadMessages, object: nil)
    }
    
    func showAcceptControllerFromMapVC(notification: NSNotification) {
        if SpaceInUser.userIsLoggedIn() {
            
            if let push = notification.userInfo?["push"] as? Push, let user = notification.userInfo?["user"] as? SpaceUser {
                
                let invitationController = InvitationController()
                
                invitationController.chatUser = user
                invitationController.push = push
                invitationController.modalPresentationStyle = .overCurrentContext
                invitationController.modalTransitionStyle = .crossDissolve
                self.present(invitationController, animated: false, completion: nil)
            }
            
        }
    }
    
    func setPushLabel() {
        
        pushCount = 0
        
        if SpaceInUser.userIsLoggedIn() {
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            let pushRef = Database.database().reference().child("push-table")
            
            pushRef.queryOrdered(byChild: "toId").queryEqual(toValue: uid).observe(.childAdded, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let push = Push(dictionary: dictionary)
                    push.pushId = snapshot.key
                    if push.pushKey == 0 {
                        
                        self.pushCount += 1
                        self.totalPushCount += self.pushCount
                        self.setPushLabelWithTotalPushCount(self.totalPushCount)
                    }
                    
                }
                
            }, withCancel: nil)
            
//            let ref = Database.database().reference().child("user-messages").child(uid)
//            ref.observe(.childAdded, with: { (snapshot) in
//
//                let userId = snapshot.key
//                ref.child(userId).observe(.childAdded, with: { (snapshot) in
//
//                    let messageId = snapshot.key
//
//                    self.fetchMessageWithMessageId(messageId: messageId)
//
//                }, withCancel: nil)
//            }, withCancel: nil)
            
        }

    }
    
    fileprivate func fetchMessageWithMessageId(messageId: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let messageReference = Database.database().reference().child("messages").child(messageId)
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    
                    let ref = Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).child("lastSeenTimeStamp")
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let lastSeenTimeStamp = snapshot.value as? NSNumber {
                            
                            if chatPartnerId == message.fromId {
                                if (message.timestamp?.doubleValue)! > lastSeenTimeStamp.doubleValue {
                                    
                                    if let count = self.messagesDictionary[chatPartnerId]?.newMessageCount {
                                        message.newMessageCount = count + 1
                                    } else {
                                        message.newMessageCount = 1
                                    }
                                }
                            }
                            self.messagesDictionary[chatPartnerId] = message
                            self.setPushCountForMessages()
                        }
                    })
                }
            }
            
        }, withCancel: nil)
    }
    
    private func setPushCountForMessages() {
        self.messages.removeAll()
        self.messages = Array(self.messagesDictionary.values)
        
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
            
        })
        
        self.totalPushCount -= self.newMessageCount
        self.newMessageCount = 0
        for message in self.messages {
            if let newMessageCount = message.newMessageCount {
                self.newMessageCount += newMessageCount
            }
        }
        
        self.totalPushCount += self.newMessageCount
        self.setPushLabelWithTotalPushCount(self.totalPushCount)
    }
    
    func resetPushLabelWhenRemovedMessage(notification: NSNotification) {
        
        if let userKey = notification.userInfo?["userKey"] as? String {
            self.messagesDictionary.removeValue(forKey: userKey)
            
            self.setPushCountForMessages()
        }
        
    }
    
    private func setPushLabelWithTotalPushCount(_ totalPushCount: Int) {
        if totalPushCount > 0 {
            self.pushLabel.text = String(totalPushCount)
            self.pushLabel.isHidden = false
        } else {
            self.pushLabel.isHidden = true
        }
    }
    
    @objc fileprivate func setPlusPushCountForNewMessage(notification: NSNotification) {
        
        if let newMessages = notification.userInfo?["newMessages"] as? Int {
            
            self.totalPushCount -= self.newMessageCount
            self.newMessageCount = newMessages
            self.totalPushCount += self.newMessageCount
            self.setPushLabelWithTotalPushCount(self.totalPushCount)
        }
        
    }
    
    @objc fileprivate func setReadPushCountForNewMessage(notification: NSNotification) {
        
        if let readMessages = notification.userInfo?["readMessages"] as? Int {
            
            self.totalPushCount -= self.newMessageCount
            self.newMessageCount -= readMessages
            self.totalPushCount += self.newMessageCount
            self.setPushLabelWithTotalPushCount(self.totalPushCount)
        }
        
    }
    
    func resetPushLabelWithReadMessage(notification: NSNotification) {
        
        if let index = notification.userInfo?["index"] as? Int {
            self.totalPushCount -= self.newMessageCount
            self.newMessageCount = 0
            
            for i in 0..<messages.count {
                messages[index].newMessageCount = nil
                if let newMessageCount = messages[i].newMessageCount {
                    self.newMessageCount += newMessageCount
                }
            }
            
            self.totalPushCount += self.newMessageCount
            self.setPushLabelWithTotalPushCount(self.totalPushCount)
        }
    }
    
//    func showAcceptControllerFromMapVC(notification: NSNotification) {
//        if SpaceInUser.userIsLoggedIn() {
//
//            if let push = notification.userInfo?["push"] as? Push, let user = notification.userInfo?["user"] as? SpaceUser {
//
//                let invitationController = InvitationController()
//
//                invitationController.chatUser = user
//                invitationController.push = push
//                invitationController.modalPresentationStyle = .overCurrentContext
//                invitationController.modalTransitionStyle = .crossDissolve
//                self.present(invitationController, animated: false, completion: nil)
//            }
//
//        }
//    }
    
    private func checkPushExist() {
        
        if SpaceInUser.userIsLoggedIn() {
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            let pushRef = Database.database().reference().child("push-table")
            
            pushRef.queryOrdered(byChild: "toId").queryEqual(toValue: uid).observe(.childAdded, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let push = Push(dictionary: dictionary)
                    push.pushId = snapshot.key
                    if push.pushKey == 0 {
                        
                        
                        if let fromId = push.fromId {
                            let userRef = Database.database().reference().child("users").child(fromId)
                            
                            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                if let dictionary = snapshot.value as? [String: AnyObject] {
                                    let user = SpaceUser()
                                    user.userId = snapshot.key
                                    user.setValuesForKeys(dictionary)
                                    
                                    
                                    let state: UIApplicationState = UIApplication.shared.applicationState
                                    print(state.hashValue)
                                    
                                    
                                    let invitationController = InvitationController()
                                    
                                    invitationController.chatUser = user
                                    invitationController.push = push
                                    invitationController.modalPresentationStyle = .overCurrentContext
                                    invitationController.modalTransitionStyle = .crossDissolve
                                    self.present(invitationController, animated: false, completion: nil)
                                    
                                }
                            }, withCancel: nil)
                        }
                    }
                }
                
            }, withCancel: nil)
        }
    }

    
    private func handleUpdatiingLocationTimer() {
        
        updatingLocationTimer.invalidate()
        
        
        updatingLocationTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(hadleUpdationLocationWithFirebase), userInfo: nil, repeats: true)
    }
    
    func hadleUpdationLocationWithFirebase() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        if SpaceInUser.userIsLoggedIn() {
            let geoFireRef = Database.database().reference().child("users").child(uid).child("user_location")
            let geoFire = GeoFire(firebaseRef: geoFireRef)
            
            if let location = self.mapView.userLocation.location {
                Global.currentUserLocation = location
                
                print("updated global location", Global.currentUserLocation)
                
                geoFire?.setLocation(Global.currentUserLocation, forKey: uid)
            }
            
        }
        
    }
    
    
    fileprivate func addNotificationObserversWithFetch() {
        addNotificationRemoveFetchUsers()
        addNotificationFetchUsers()
    }
    
    private func addNotificationRemoveFetchUsers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(removeUsersWhenLogout), name: .FetchUsersWhenLogOut, object: nil)
    }
    
    private func addNotificationFetchUsers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(fetchUsers), name: .FetchUsers, object: nil)
    }
    
    func removeUsersWhenLogout() {
        self.mapView.removeOtherUsersPin()
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: .FetchUsersWhenLogOut, object: nil)
        nc.removeObserver(self, name: .FetchUsers, object: nil)
    }
    
    func fetchUsers() {
        
        print("distance", Global.currentDistance)
        
        self.users.removeAll()
        if SpaceInUser.userIsLoggedIn() {
            mapView.showsUserLocation = true
//            if let location = self.mapView.userLocation.location {
//                Global.currentUserLocation = location
//            }

            removeUsersWhenLogout()
            addNotificationObserversWithFetch()

            let userRef = Database.database().reference().child("users")
            
            userRef.observe(.childAdded, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let user = SpaceUser()
                    user.userId = snapshot.key
                    
                    let userPostRef = Database.database().reference().child("user-posts").child(user.userId!)
                    var count = 0
                    var counter = 0
                    userPostRef.observe(.childAdded, with: { (snapshotPost) in
                        
                        let postId = snapshotPost.key
                        let postsRef = Database.database().reference().child("posts").child(postId)
                        
                        postsRef.observeSingleEvent(of: .value, with: { (snapshotCount) in
                            
                            guard let dictionaryPost = snapshotCount.value as? [String: AnyObject] else {
                                return
                            }
                            let post = Post(dictionary: dictionaryPost)
                            
                            let postedDay = returnDayWithDateformatter(date: post.timestamp as! Double)
                            counter += 1
                            if postedDay < 7 {
                                if postedDay != 0 {
                                    count += 1
                                    print("filtered posted day", postedDay)
                                }
                                
                            }
                            if counter == Int(snapshotCount.childrenCount) {
                                user.postCount = count as NSNumber
                            }
                        }, withCancel: nil)
                        
                    }, withCancel: nil)
                    
                    user.setValuesForKeys(dictionary)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        if user.user_location != nil {
                            
                            let geoFireRef = userRef.child(user.userId!).child("user_location")
                            let geoFire = GeoFire(firebaseRef: geoFireRef)
                            let circleQuery = geoFire?.query(at: Global.currentCenterLocation, withRadius: Global.currentDistance)
                            
                            circleQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                                
                                let userId = key
                                
                                guard let uid = Auth.auth().currentUser?.uid else {
                                    return
                                }
                                if uid != userId {
                                    
                                    var canShow = getDistance(firstLocation: Global.currentUserLocation, secondLocation: location)
                                    canShow = true
                                    
                                    if canShow == true {
                                        user.postCount = count as NSNumber
                                        self.users.append(user)
                                    }
                                    
                                } else {
                                    user.postCount = 0
                                    self.users.append(user)
                                    self.spaceUser = user
                                }
                            })
                        }

                    })
                }
            }, withCancel: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            print("users", self.users.count)
            self.addOtherUsersAnnotation()
        })
    }
    
    func alertMessageNotLogin() {
        showAlertMessage(vc: self, titleStr: "Oops!", messageStr: "Please Log in to start chat")
    }
    
    func addOtherUsersAnnotation() {
        for user in users {
            
            if let count = user.postCount {
                print("userCount", count, user.name!)
            }
            
            
            
            let geoLocationDic = user.user_location?[user.userId!]
            let geoLocation = geoLocationDic?["l"] as! [NSNumber]
            let lat = geoLocation[0]
            let lon = geoLocation[1]
            
//            self.mapView.addOtherUsersPin(withUser: user, withCoordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon)))
            
            if user.userId == Auth.auth().currentUser?.uid {
                self.mapView.addOtherUsersPin(withUser: user, withCoordinate: self.mapView.userLocation.coordinate)
            } else {
                self.mapView.addOtherUsersPin(withUser: user, withCoordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon)))
            }
//
            
        }
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginRegisterVC = nil
        viewHasAppeared = true
    }
    
    func isZoomedOut() -> Bool {
        if mapView.didFinishLoadingMap {
            return mapView.camera.altitude >= MapViewController.zoomLevelForShowingSpaceinView
        } else {
            return true
        }
        
    }
}


//MARK: - Login/Register
extension MapViewController {
    
    fileprivate func presentLoginRegister() {
        if loginRegisterVC == nil {
            loginRegisterVC = LoginRegisterVC()
        }
        present(loginRegisterVC!, animated: true, completion: nil)
    }
}

//MARK: - User actual location
extension MapViewController {
    
    fileprivate func addObserversForLocationManager() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(userLocationSet), name: .didSetUserLocation, object: nil)
        nc.addObserver(self, selector: #selector(userLocationDeniedOrRestricted), name: .deniedLocationPermission, object: nil)
        nc.addObserver(self, selector: #selector(userLocationDeniedOrRestricted), name: .restrictedLocationPermission, object: nil)
    }
    
    fileprivate func removeSelfAsObserver() {
        let nc = NotificationCenter.default
        nc.removeObserver(self)
        
//        nc.removeObserver(self, name: .didSetUserLocation, object: nil)
//        nc.removeObserver(self, name: .deniedLocationPermission, object: nil)
//        nc.removeObserver(self, name: .restrictedLocationPermission, object: nil)
    }
    
    func userLocationSet() {
        removeSelfAsObserver()
        addNotificationObserversWithFetch()
        guard let location = mapView.userLocation.location else { return }

//        let location = Global.currentUserLocation
        
        Global.currentCenterLocation = location
        guard let currentUser = SpaceInUser.current else { return }
        
        if isZoomedOut() {
            mapView.shouldRemoveUserPinOnMovement = false
            mapView.setToLocation(location: location, zoomType: .leaveAlone, animated: true)
        
            currentUser.movedToCoordinate(coordinate: location.coordinate)
//            mapView.addUserPin(withCoordinate: currentUser.getCoordinate()!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                //we add a second of lag. otherwise the region did change will cause issues
                self.mapView.shouldRemoveUserPinOnMovement = true
            })
        } else {
            mapView.setToLocation(location: location, zoomType: .leaveAlone, animated: true)
            
            
        }
    }
    
    func userLocationDeniedOrRestricted() {
        removeSelfAsObserver()
    }
    
    fileprivate func savedLocation() -> CLLocation {
        return CLLocation()
    }
    
    fileprivate func defaultKickoffLocation() -> CLLocation {
        return CLLocation()
    }

}


//MARK: - Interactions with the mapview
extension MapViewController: MapViewDelegate {
    
    fileprivate func setupInitialMapViewStateIfNeccessary() {
        if didSetupInitialMap {
            return
        }
        
        let zoomTypeToUse = weCanSetupMapView() ? zoomType! : MapViewZoomType.defaultType
        mapView.setToLocation(location: currentLocation!, zoomType: zoomTypeToUse, animated: false)
        
        didSetupInitialMap = true
    }
    
    fileprivate func weCanSetupMapView() -> Bool {
        return currentLocation != nil && zoomType != nil
    }
    
    func centerChangedToCoordinate(coordinate: CLLocationCoordinate2D) {
        
        let weAreZoomedOut = isZoomedOut()
        logoView.isHidden = !weAreZoomedOut
        showStatusBar(show: weAreZoomedOut)
        
        //we are not saving the state if we are zoomed out
        if !weAreZoomedOut && didSetupInitialMap {
            currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            SpaceInUser.current?.movedToCoordinate(coordinate: coordinate)
            saveState()
        }
    }
    
    
    
    fileprivate func showStatusBar(show: Bool) {
         UIApplication.shared.isStatusBarHidden = !show
    }
}


//MARK:- UI calls
extension MapViewController {
    fileprivate func addViews() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        logoContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoContainerView)
        logoContainerView.addSubview(logoView)
        setupButtons()
        setupLogoView()

    }
    
    fileprivate func setProfileButtonImage() {
        var image: UIImage
        var contentMode = UIViewContentMode.scaleAspectFit
        
        if let spaceInUserImage = SpaceInUser.current?.image {
            image = spaceInUserImage
            contentMode = .scaleAspectFill
        } else {
            image = UIImage(named: AssetName.profilePlaceholder.rawValue)!
        }

        profileButton.setImage(image, for: .normal)
        profileButton.imageView?.contentMode = contentMode
    }
    
    fileprivate func constrain() {
        if didConstrain == false {
            constrainMapView()
            constrainLogoView()
            constrainButtons()
        }
    }
    
    fileprivate func constrainMapView() {
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    fileprivate func constrainLogoView() {
        logoContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: MapViewController.spaceinViewPadding).isActive = true
        logoContainerView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        logoContainerView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        logoView.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor).isActive = true
        logoView.topAnchor.constraint(equalTo: logoContainerView.topAnchor).isActive = true
        logoView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
    }
    
    fileprivate func constrainButtons() {
        constrainProfileButton()
        constrainLocateMeButton()
        constrainNotificationsButton()
    }
    
    private func constrainProfileButton() {
        profileContainerButton.constrainWidthAndHeightToValueAndActivate(value: MapViewController.buttonwidthHeights)
        profileContainerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileContainerButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -MapViewController.buttonBottomPadding).isActive = true
    }
    
    private func constrainLocateMeButton() {
        locateMeButton.constrainWidthAndHeightToValueAndActivate(value: MapViewController.buttonwidthHeights * 0.75)
        locateMeButton.centerYAnchor.constraint(equalTo: profileContainerButton.centerYAnchor).isActive = true
         locateMeButton.leftAnchor.constraint(equalTo: profileContainerButton.rightAnchor, constant: MapViewController.buttonPadding).isActive = true
    }
    
    private func constrainNotificationsButton() {
        notificationsButton.constrainWidthAndHeightToValueAndActivate(value: MapViewController.buttonwidthHeights)
        notificationsButton.centerYAnchor.constraint(equalTo: profileContainerButton.centerYAnchor).isActive = true
        notificationsButton.rightAnchor.constraint(equalTo: profileContainerButton.leftAnchor, constant: -MapViewController.buttonPadding).isActive = true
        
        view.addSubview(pushLabel)
        
        pushLabel.constrainWidthAndHeightToValueAndActivate(value: 16)
        pushLabel.centerXAnchor.constraint(equalTo: notificationsButton.centerXAnchor, constant: 20).isActive = true
        pushLabel.centerYAnchor.constraint(equalTo: notificationsButton.centerYAnchor, constant: 20).isActive = true
        self.pushLabel.isHidden = true
    }
    
    private func setupLogoView() {
        logoView.text = SpaceinCopy.spaceInFloatingLabelText.rawValue
        logoView.textColor =  StyleGuideManager.floatingSpaceinLabelColor
        logoView.font = StyleGuideManager.floatingSpaceinLabelFont
        logoView.textAlignment = .center
        
        logoView.layer.shadowColor = StyleGuideManager.floatingSpaceinNeonBackground.cgColor
        logoView.layer.shadowRadius = 25
        logoView.layer.shadowOpacity = 0.9
        logoView.layer.shadowOffset = CGSize(width: 0, height: 0)
        logoView.layer.masksToBounds = false
        
        logoContainerView.contentView = logoView
        logoContainerView.isShimmering = true
        logoContainerView.shimmeringAnimationOpacity = 0.6
        //logoContainerView.shimmeringOpacity = 0.1
    }
    
    private func setupButtons() {
        
        let buttons = [profileContainerButton, notificationsButton, locateMeButton]
        
        for button in buttons {
            view.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupLocateMeButton()
        setupNotificationButton()
        setupProfileButton()
    }
    
    private func setupNotificationButton() {
        let notificationImage = UIImage(named: AssetName.notification.rawValue)
        setupRounded(button: notificationsButton, withImage: notificationImage)
        
        notificationsButton.addTarget(self, action: #selector(notificationsButtonPressed), for: .touchUpInside)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(notificationButtonLongPressed(gesture:)))
        longPressRecognizer.minimumPressDuration = 0.5
        longPressRecognizer.delegate = self
        notificationsButton.addGestureRecognizer(longPressRecognizer)
    }
    
    private func setupLocateMeButton() {
        locateMeButton.setTitle("", for: .normal)
        locateMeButton.setImage(UIImage(named: AssetName.locationIcon.rawValue), for: .normal)
        locateMeButton.imageView?.contentMode = .scaleAspectFit
        locateMeButton.addTarget(self, action: #selector(tappedLocatedMe), for: .touchUpInside)
    }
    
    private func setupProfileButton() {
        profileContainerButton.titleLabel?.text = ""
        profileContainerButton.backgroundColor = UIColor.clear
        setupRounded(button: profileContainerButton, withImage: nil)
        
        setProfileButtonImage()

        profileButton.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(profileButtonLongPressed(gesture:)))
        longPressRecognizer.minimumPressDuration = 0.5
        longPressRecognizer.delegate = self
        profileButton.addGestureRecognizer(longPressRecognizer)

        
        profileContainerButton.addSubview(profileButton)
        
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.widthAnchor.constraint(equalTo: profileContainerButton.widthAnchor, constant: -5).isActive = true
        profileButton.heightAnchor.constraint(equalTo: profileContainerButton.heightAnchor, constant: -5).isActive = true
        profileButton.centerXAnchor.constraint(equalTo: profileContainerButton.centerXAnchor).isActive = true
        profileButton.centerYAnchor.constraint(equalTo: profileContainerButton.centerYAnchor).isActive = true
        
        profileButton.layer.borderWidth = 0.0
    }
    
    private func setupRounded(button: RoundedButton, withImage image: UIImage?) {
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        
        button.borderWidth = 1.0
    }
}

//MARK: - Locate me
extension MapViewController {
    func tappedLocatedMe() {
        
        addObserversForLocationManager()
        let status = LocationManager.sharedInstance.userLocationStatus()
        switch status {
        case .authorized:
            LocationManager.sharedInstance.startTrackingUser()
            break
        case .unknown:
            LocationManager.sharedInstance.requestUserLocation()
            break
        case .denied:
            tellUserToUpdateLocationSettings()
            break
        default:
            print("we don't know the location status")
            break
            
        }
    }
}


//MARK: - Joystick setup 
extension MapViewController {
    fileprivate func tellUserToUpdateLocationSettings() {
        let alertMessage = AlertMessage(title: AlertMessages.locationPermissionResetTitle.rawValue, subtitle: AlertMessages.locationPermissionResetSubTitle.rawValue, actionButtontitle: AlertMessages.okayButtonTitle.rawValue, secondButtonTitle: nil)
        let alertController = UIAlertController(title: alertMessage.alertTitle, message: alertMessage.alertSubtitle, preferredStyle: .alert)
        let okAction = UIAlertAction(title: alertMessage.actionButton1Title, style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}


//MARK: - State Management 
extension MapViewController {
    func saveState() {
        let defaults = UserDefaults.standard
        saveMapStatewithDefaults(defaults: defaults)
        defaults.synchronize()
    }
    
    func appEntetedBackground() {
        if mapView.didFinishLoadingMap == true {
            mapView.didFinishLoadingMap = false
        }
    }
    
    func appEnteredForeground() {
        if mapView.didFinishLoadingMap == false && viewHasAppeared {
            mapView.didFinishLoadingMap = true
        }
    }
    
    fileprivate func saveMapStatewithDefaults(defaults: UserDefaults) {
        let lastKnownLat = CGFloat(currentLocation!.coordinate.latitude)
        let lastKnownLong = CGFloat(currentLocation!.coordinate.longitude)

        defaults.set(lastKnownLat, forKey: UserDefaultKeys.lastKnownSpaceInLattitude.rawValue)
        defaults.set(lastKnownLong, forKey: UserDefaultKeys.lastKnownSpaceInLongitude.rawValue)
    }
}


//MARK: - Profile
extension MapViewController {
    @objc fileprivate func profileButtonPressed() {
        if SpaceInUser.userIsLoggedIn() {
            presentProfileVC(user: SpaceInUser.current!)

            
//            self.presentUserProfileVC(user: self.spaceUser!)
            
        } else {
            presentLoginRegister()
        }
    }
    
    fileprivate func presentProfileVC(user: SpaceInUser) {
        let profileVC = ProfileVC(user: user, isCurrentUser: user == SpaceInUser.current)
        profileVC.modalPresentationStyle = .custom
        profileVC.modalTransitionStyle = .crossDissolve
        self.present(profileVC, animated: false, completion: nil)
    }
    
    func presentUserProfileVC(user: SpaceUser) {
        let profileVC = UserProfileController(user: user)
        profileVC.mapViewController = self
        profileVC.controllerStauts = .mapViewController
        profileVC.modalPresentationStyle = .overCurrentContext
        profileVC.modalTransitionStyle = .crossDissolve
        self.present(profileVC, animated: false, completion: nil)
    }
    
    func presentChatOnebyOneController(user: SpaceUser) {
        let chatOnebyOneController = ChatOnebyOneController()
        chatOnebyOneController.chatUser = user
        chatOnebyOneController.modalPresentationStyle = .overCurrentContext
        chatOnebyOneController.modalTransitionStyle = .crossDissolve
        self.present(chatOnebyOneController, animated: false, completion: nil)
    }
    
    @objc fileprivate func profileButtonLongPressed(gesture: UIGestureRecognizer) {
        if gesture.state != UIGestureRecognizerState.ended {
            return
        }
        
        if !SpaceInUser.userIsLoggedIn() {
            return
        }
        
        presentPostHistoryController(user: self.spaceUser!)
        
    }
    
    func presentPostHistoryController(user: SpaceUser) {
        let postHistoryController = PostHistoryController()
        postHistoryController.postUser = user
        postHistoryController.modalPresentationStyle = .overCurrentContext
        postHistoryController.modalTransitionStyle = .crossDissolve
        self.present(postHistoryController, animated: false, completion: nil)
    }
    
    func presentInvitationController() {
        
        if let currentController = currentViewController() {
            currentController.showErrorAlert("Success!", message: "You sent invitation to chat with user", action: nil, completion: nil)
        }
        
        
        
    }
    
    func presentAlreadySentInvitationController() {
        if let currentController = currentViewController() {
            currentController.showErrorAlert("You already sent invitation to this user. But he didn't accept it", message: "Please wait until he accept your invitation!", action: nil, completion: nil)
        }
        
        
    }
    
    func presentAlreadyReceiveInvitaonController() {
        if let currentController = currentViewController() {
            currentController.showErrorAlert("You already Received invitation from this user. But you didn't accept it", message: "Please accept invitation to chat this user!", action: nil, completion: nil)
        }
        
    }
}


//MARK: - Notifications

extension MapViewController {
    @objc fileprivate func notificationsButtonPressed() {
        if !SpaceInUser.userIsLoggedIn() {
            return
        }
        presentNotificationsVC()
    }
    
    private func presentNotificationsVC() {
        
        if self.pushCount == 0 {
            let chatHistoryController = ChatHistoryController()
            chatHistoryController.modalPresentationStyle = .overCurrentContext
            chatHistoryController.modalTransitionStyle = .crossDissolve
            self.present(chatHistoryController, animated: false, completion: nil)
        } else {
            self.showInvitationController()
        }
    }
    
    private func showInvitationController() {
        if SpaceInUser.userIsLoggedIn() {
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            let pushRef = Database.database().reference().child("push-table")
            pushRef.queryOrdered(byChild: "toId").queryEqual(toValue: uid).observeSingleEvent(of: .childAdded, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let push = Push(dictionary: dictionary)
                    push.pushId = snapshot.key
                    if push.pushKey == 0 {
                        
                        
                        if let fromId = push.fromId {
                            let userRef = Database.database().reference().child("users").child(fromId)
                            
                            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                if let dictionary = snapshot.value as? [String: AnyObject] {
                                    let user = SpaceUser()
                                    user.userId = snapshot.key
                                    user.setValuesForKeys(dictionary)
                                    
                                    
                                    let state: UIApplicationState = UIApplication.shared.applicationState
                                    print(state.hashValue)
                                    
                                    
                                    if let currentControllers = currentViewController()  {
                                        
                                        let invitationController = InvitationController()
                                        invitationController.mapViewController = self
                                        invitationController.chatUser = user
                                        invitationController.push = push
                                        invitationController.modalPresentationStyle = .overCurrentContext
                                        invitationController.modalTransitionStyle = .crossDissolve
                                        currentControllers.present(invitationController, animated: false, completion: nil)
                                        
                                        
                                        print("pushcoming_notification")
                                    }
                                }
                                
                                
                            }, withCancel: nil)
                        }
                    }
                    
                }

            }, withCancel: nil)
            
        } else {
            self.showErrorAlert(message: "You signed out. Please sign in!")
        }

    }
    
    @objc fileprivate func notificationButtonLongPressed(gesture: UIGestureRecognizer) {
        
        if gesture.state != UIGestureRecognizerState.ended {
            return
        }
        let createPostController = CreatePostController()
        createPostController.modalPresentationStyle = .overCurrentContext
        createPostController.modalTransitionStyle = .crossDissolve
        self.present(createPostController, animated: false, completion: nil)
        
    }
}


//MARK: - External Events

extension MapViewController {
    fileprivate func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(profilePictureChanged), name: .DidSetCurrentUserProfilePicture, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(alertMessageNotLogin), name: .NotLogInMessage, object: nil)
    }
    
    @objc private func profilePictureChanged() {
        DispatchQueue.main.async { [weak self] in
            self?.setProfileButtonImage()
            self?.mapView.reloadUserAnnotationIfNeeded()
        }
        
        // who needs to know about the picture change?
        //map pin
        //center icon
    }
}


extension MapViewController: UIGestureRecognizerDelegate {
    
//    fileprivate func addPanGestureRecognizer() {
//        
//        let panRec = UIPanGestureRecognizer(target: self, action: #selector(didDragMap(gestureRecognizer:)))
//        panRec.delegate = self
//        self.mapView.addGestureRecognizer(panRec)
//        
//    }
//    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
//    
//    func didDragMap(gestureRecognizer: UIGestureRecognizer) {
//        if gestureRecognizer.state == .ended {
//            print("drag ended")
//        }
//    }
    
}






////Mark:- Zoom
//extension MapViewController {
//    fileprivate func processZoomAction(zoomIn: Bool) {
//        if mapView.isIn3DMode() {
//            print("3d")
//        } else {
//
////            //  until the altitude reaches 36185300.1305086 use the camera to zoom since changing the region looks like crap
////
////            if mapView.camera.altitude > 4_000_000.0 {
////                MKMapView.animate(withDuration: 0.3, animations: {
////                    let change = 0.03
////                    let delta = zoomIn ? 1 - change : 1 + change
////                    let newAltitude = mapView.camera.altitude * delta
////
////                    mapView.camera.altitude = newAltitude
////                    print("camera")
////                })
////
////            } else {
//            print(mapView.camera.altitude)
//
//            if mapView.camera.altitude > 10_700_000 && mapView .camera.altitude < 28_700_000 {
//                let change = 0.03
//                let delta = zoomIn ? 1 - change : 1 + change
//                let newAltitude = mapView.camera.altitude * delta
//
//                mapView.camera.altitude = newAltitude
//                print("camera")
//            } else {
//                let change = 0.55
//                let delta = zoomIn ? 1 - change : 1 + change
//                var span = mapView.region.span
//                print("region")
//                span.latitudeDelta *= delta
//                span.longitudeDelta *= delta
//
//                let newRegion = MKCoordinateRegion(center: mapView.centerCoordinate, span: span)
//                mapView.setRegion(newRegion, animated: true)
//            }
//
//        }
//    }
//}


