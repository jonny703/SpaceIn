//
//  AppDelegate.swift
//  SpaceIn
//
//  Created by John Nik on 11/15/16.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import MapKit
import Fabric
import Crashlytics
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, OSPermissionObserver, OSSubscriptionObserver {
    
    var window: UIWindow?
    fileprivate var mapVC: MapViewController?
    fileprivate var tutorialVC: TutorialVC?
    
    var launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    var notificationReceivedBlock: OSHandleNotificationReceivedBlock?
    var notificationOpenedBlock: OSHandleNotificationActionBlock?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.launchOptions = launchOptions
        
        setupOneSignal(launchOptions: launchOptions)
        
        Fabric.with([Crashlytics.self])
        
        setupManagers()
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true

        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        Global.isLogIn = UserDefaults.standard.value(forKey: "IsLogIn") as? Bool ?? false
        
        if let userData = UserDefaults.standard.value(forKey: "CurrentUser") {
            Global.currentUser = NSKeyedUnarchiver.unarchiveObject(with: userData as! Data) as! SpaceUser
        }
        
        self.determineAndLoadInitialVC()

        return true
    }
    
    func setupOneSignal(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
        
        notificationReceivedBlock = { notification in
            
            print("Received Notification: \(notification!.payload.notificationID)")
            
            let state: UIApplicationState = UIApplication.shared.applicationState
            if state == UIApplicationState.background {
                
            } else if state == UIApplicationState.active {
                
//                if let currentControllers = currentViewController()  {
//                    let invitationController = InvitationController()
//                    
////                    invitationController.chatUser = user
//                    
//                    invitationController.modalPresentationStyle = .overCurrentContext
//                    invitationController.modalTransitionStyle = .crossDissolve
//                    currentControllers.present(invitationController, animated: false, completion: nil)
//                    
//                    
//                    print("pushcoming_recieve block")
//                }
            }
            
            
        }
        
        notificationOpenedBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
            print("Message = \(payload!.body)")
            print("badge number = \(payload?.badge)")
            print("notification sound = \(payload?.sound)")
            
            let state: UIApplicationState = UIApplication.shared.applicationState
            if state == UIApplicationState.background {
                
                if let additionalData = result!.notification.payload!.additionalData {
                    print("additionalData = \(additionalData)")
                    
                    let fromId = additionalData["fromId"] as! String
                    let pushId = additionalData["pushId"] as! String
                    
                    let pushRef = Database.database().reference().child("push-table").child(pushId)
                    
                    pushRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            
                            let push = Push(dictionary: dictionary)
                            push.pushId = pushId
                            
                            if push.pushKey == 0 {
                                let userRef = Database.database().reference().child("users").child(fromId)
                                
                                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let dictionary = snapshot.value as? [String: AnyObject] {
                                        
                                        let user = SpaceUser()
                                        user.userId = snapshot.key
                                        user.setValuesForKeys(dictionary)
                                        if let currentControllers = currentViewController()  {
                                            let invitationController = InvitationController()
                                            
                                            invitationController.chatUser = user
                                            invitationController.push = push
                                            invitationController.modalPresentationStyle = .overCurrentContext
                                            invitationController.modalTransitionStyle = .crossDissolve
                                            currentControllers.present(invitationController, animated: false, completion: nil)
                                            
                                            
                                            print("pushcoming_pushaction")
                                        }
                                        
                                    }
                                    
                                    
                                }, withCancel: nil)
                            } else if push.pushKey == 1 {
                                
                            } else {
                                
                            }
                            
                        }
                        
                    }, withCancel: nil)
                    
                }
            } else if state == UIApplicationState.active {
                
            } else if state == UIApplicationState.inactive {
//                if let additionalData = result!.notification.payload!.additionalData {
//                    print("additionalData = \(additionalData)")
//                    
//                    let fromId = additionalData["fromId"] as! String
//                    let pushId = additionalData["pushId"] as! String
//                    
//                    let pushRef = Database.database().reference().child("push-table").child(pushId)
//                    
//                    pushRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                        
//                        if let dictionary = snapshot.value as? [String: AnyObject] {
//                            
//                            let push = Push(dictionary: dictionary)
//                            push.pushId = pushId
//                            
//                            if push.pushKey == 0 {
//                                let userRef = Database.database().reference().child("users").child(fromId)
//                                
//                                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                                    if let dictionary = snapshot.value as? [String: AnyObject] {
//                                        
//                                        let user = SpaceUser()
//                                        user.userId = snapshot.key
//                                        user.setValuesForKeys(dictionary)
//                                        if let currentControllers = currentViewController()  {
//                                            let invitationController = InvitationController()
//                                            
//                                            invitationController.chatUser = user
//                                            invitationController.push = push
//                                            invitationController.modalPresentationStyle = .overCurrentContext
//                                            invitationController.modalTransitionStyle = .crossDissolve
//                                            currentControllers.present(invitationController, animated: false, completion: nil)
//                                            
//                                            
//                                            print("pushcoming_inactive")
//                                        }
//                                        
//                                    }
//                                    
//                                    
//                                }, withCancel: nil)
//                            } else if push.pushKey == 1 {
//                                
//                            } else {
//                                
//                            }
//                            
//                        }
//                        
//                    }, withCancel: nil)
//                    
//                }

            }
            
            if let additionalData = result!.notification.payload!.additionalData {
                print("additionalData = \(additionalData)")
                
                
                if let actionSelected = payload?.actionButtons {
                    print("actionSelected = \(actionSelected)")
                }
                
                // DEEP LINK from action buttons
                if let actionID = result?.action.actionID {
                    
                    print("actionID = \(actionID)")
                    
                    if actionID == "id2" {
                        print("do something when button 2 is pressed")
                        
                        
                    } else if actionID == "id1" {
                        print("do something when button 1 is pressed")
                        
                    }
                }
            }
        }

        
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.setupOnesignalObserver), name: .SetupOneSignal, object: nil)
        
        
    }
    
    func setupOnesignalObserver() {
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        // Replace '11111111-2222-3333-4444-0123456789ab' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "65e296d1-6448-4989-b9fc-849eb21b218b", handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Add your AppDelegate as an obsserver
        OneSignal.add(self as OSPermissionObserver)
        
        OneSignal.add(self as OSSubscriptionObserver)
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let hasPrompted = status.permissionStatus.hasPrompted
        if hasPrompted == false {
            // Call when you want to prompt the user to accept push notifications.
            // Only call once and only if you set kOSSettingsKeyAutoPrompt in AppDelegate to false.
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                if accepted == true {
                    print("User accepted notifications: \(accepted)")
                } else {
                    print("User accepted notificationsfalse: \(accepted)")
                }
            })
        } else {
        }
        
        if let userID = status.subscriptionStatus.userId {
            Global.pushToken = userID
        } else {
            Global.pushToken = ""
        }
        
        
        // Sync hashed email if you have a login system or collect it.
        //   Will be used to reach the user at the most optimal time of day.
        // OneSignal.syncHashedEmail(userEmail)
    }
    
    // Add this new method
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        
        // Example of detecting answering the permission prompt
        if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("Thanks for accepting notifications!")
                
//                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
//                let hasPrompted = status.permissionStatus.hasPrompted
//                print("hasPrompted = \(hasPrompted)")
//                let userStatus = status.permissionStatus.status
//                print("userStatus = \(userStatus)")
//                let isSubscribed = status.subscriptionStatus.subscribed
//                print("isSubscribed = \(isSubscribed)")
//                let userSubscriptionSetting = status.subscriptionStatus.userSubscriptionSetting
//                print("userSubscriptionSetting = \(userSubscriptionSetting)")
//                let userID = status.subscriptionStatus.userId
//                print("userID = \(userID)")
//                let pushToken = status.subscriptionStatus.pushToken
//                print("pushToken = \(pushToken)")
//                Global.pushToken = userID!
                
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("Notifications not accepted. You can turn them on later under your iOS settings.")
                Global.pushToken = ""
            }
        }
        // prints out all properties
        print("PermissionStateChanges: \n\(stateChanges)")
    }
    
    // Output:
    /*
     Thanks for accepting notifications!
     PermissionStateChanges:
     Optional(<OSSubscriptionStateChanges:
     from: <OSPermissionState: hasPrompted: 0, status: NotDetermined>,
     to:   <OSPermissionState: hasPrompted: 1, status: Authorized>
     >
     */
    
    // TODO: update docs to change method name
    // Add this new method
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
    }
    
    // Output:
    
    /*
     Subscribed for OneSignal push notifications!
     PermissionStateChanges:
     Optional(<OSSubscriptionStateChanges:
     from: <OSSubscriptionState: userId: (null), pushToken: 0000000000000000000000000000000000000000000000000000000000000000 userSubscriptionSetting: 1, subscribed: 0>,
     to:   <OSSubscriptionState: userId: 11111111-222-333-444-555555555555, pushToken: 0000000000000000000000000000000000000000000000000000000000000000, userSubscriptionSetting: 1, subscribed: 1>
     >
     */

    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        if (self.mapVC != nil), !self.mapVC!.isZoomedOut() {
            self.mapVC?.saveState()
        }

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if (self.mapVC != nil), !self.mapVC!.isZoomedOut() {
            self.mapVC?.saveState()
        }
        self.mapVC?.appEntetedBackground()
        
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


    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.mapVC?.appEnteredForeground()
        print("we're back")
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let values = ["isLogIn": true] as [String : AnyObject]
        let ref = Database.database().reference().child("users").child(uid)
        ref.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
        }
        
//        showAcceptControllerWhenReceiveRequest()
    }
    
    func showAcceptControllerWhenReceiveRequest() {
        
        if SpaceInUser.userIsLoggedIn() {
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            let pushRef = Database.database().reference().child("push-table")
            
            pushRef.queryOrdered(byChild: "toId").queryEqual(toValue: uid).observe(.childAdded, with: { (snapshot) in
                
                print("snapshot", snapshot.value!)
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let push = Push(dictionary: dictionary)
                    push.pushId = snapshot.key
                    
                    if push.pushKey == 0 {
                        
                        print("pushcoming_background1")
                        if let fromId = push.fromId {
                            let userRef = Database.database().reference().child("users").child(fromId)
                            
                            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                if let dictionary = snapshot.value as? [String: AnyObject] {
                                    let user = SpaceUser()
                                    user.userId = snapshot.key
                                    user.setValuesForKeys(dictionary)
                                    print("pushcoming_background2")
                                    
                                    if let currentController = currentViewController()  {
                                        
                                        if !currentController.isKind(of: MapViewController.self) {
                                            let invitationController = InvitationController()
                                            
                                            invitationController.chatUser = user
                                            invitationController.push = push
                                            
                                            invitationController.modalPresentationStyle = .overCurrentContext
                                            invitationController.modalTransitionStyle = .crossDissolve
                                            currentController.present(invitationController, animated: false, completion: nil)
                                            
                                            
                                            print("pushcoming_background")
                                        } else {
                                            
                                            let dictionaryData = ["push": push, "user": user] as [String: AnyObject]
                                            let nc = NotificationCenter.default
                                            nc.post(name: .ShowAcceptController, object: nil, userInfo: dictionaryData)
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                
                            }, withCancel: nil)
                        }
                    }
                    
                }
                
            }, withCancel: nil)

            
        }

        
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if (self.mapVC != nil), !self.mapVC!.isZoomedOut() {
            self.mapVC?.saveState()
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let values = ["isLogIn": false] as [String : AnyObject]
        let ref = Database.database().reference().child("users").child(uid)
        ref.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error!)
                return
            }
        }
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options:[UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let handled = GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        
        return handled
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handled =  GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)
        return handled
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            NotificationCenter.default.post(name: .DidFailGoogleLogin, object: nil)
            print("failed to login to google \(error.localizedDescription)")
            return
        }
        
        print("we signed in with google \(user)")
        
        guard let authentication = user.authentication else {
            NotificationCenter.default.post(name: .DidFailAuthentication, object: nil)
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FirebaseHelper.loginWithCredential(credential: credential, andUser: user)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
}


// MARK: - First VC
extension AppDelegate: TutorialVCDelegate {
    
    func tutorialFinished(tutorialVC: TutorialVC) {
        
        if let usersLocation = LocationManager.sharedInstance.userLocation {
            self.setupUserSettingsWithLocation(location: usersLocation)
            Global.currentUserLocation = usersLocation
        } else {
            self.setupUserSettingsWithLocation(location: MapViewController.defaultLocation)
            Global.currentUserLocation = MapViewController.defaultLocation
        }

        self.setupUserSettingsAndLaunchMapVC()
    }
    
    fileprivate func determineAndLoadInitialVC() {
        
        let userDefaults = UserDefaults.standard
//        userDefaults.setValue(false, forKey: UserDefaultKeys.hasSeenTutorial.rawValue)
//        userDefaults.synchronize()
        let hasSeenTutorial = userDefaults.bool(forKey: UserDefaultKeys.hasSeenTutorial.rawValue)
        
        if hasSeenTutorial {
            LocationManager.sharedInstance.startTrackingUser()
            perform(#selector(setupUserSettingsAndLaunchMapVC), with: nil, afterDelay: 1.0)
//            self.setupUserSettingsAndLaunchMapVC()
        } else {
            
            self.makeTutorialViewTheFirstView()
            userDefaults.setValue(true, forKey: UserDefaultKeys.hasSeenTutorial.rawValue)
            userDefaults.synchronize()
        }
    }
    
    @objc private func setupUserSettingsAndLaunchMapVC() {
        var location: CLLocation
        
        SpaceInUser.initializeCurrentUser()
        
        //We check for location in this order 1. the spaceinuserlocation has been set 2. The location manager has a location (which means we can from tutorial most likely 3. default location
        
        if let spaceinUserCoordinate = SpaceInUser.current?.getCoordinate() {
            location = CLLocation(latitude: spaceinUserCoordinate.latitude, longitude: spaceinUserCoordinate.longitude)
            
            if let userLocation = LocationManager.sharedInstance.userLocation {
                location = userLocation
            }
            
        } else if let locationManagerLocation = LocationManager.sharedInstance.latestLocation() {
            location = locationManagerLocation
            self.setupUserSettingsWithLocation(location: locationManagerLocation)
        } else {
            location = MapViewController.defaultLocation
            self.setupUserSettingsWithLocation(location: location)
        }
        
        Global.currentUserLocation = location
        self.makeMapVCTheFirstVC(withMapVC: MapViewController(startingLocation: location, zoomType: zoomStateForMapVC()))
    }
    
    private func zoomStateForMapVC()-> MapViewZoomType {
        let userDefaults = UserDefaults.standard
        
        let hasSeenMap = userDefaults.bool(forKey: UserDefaultKeys.hasSeenMapBefore.rawValue)
        
        if hasSeenMap {
            return MapViewZoomType.zoomedOut
//            return MapViewZoomType.zoomedIn
        } else {
            userDefaults.set(true, forKey: UserDefaultKeys.hasSeenMapBefore.rawValue)
//            return MapViewZoomType.zoomedIn
            return MapViewZoomType.zoomedOut
        }
    }
    
    private func makeMapVCTheFirstVC(withMapVC: MapViewController) {
        self.mapVC = withMapVC
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = withMapVC
        self.window?.makeKeyAndVisible()
    }
    
    private func makeTutorialViewTheFirstView() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let tutorialVC = TutorialVC()
        self.tutorialVC = tutorialVC
        self.tutorialVC?.delegate = self
        self.window?.rootViewController = tutorialVC
        self.window?.makeKeyAndVisible()
    }
    
    private func setupUserSettingsWithLocation(location: CLLocation) {
        if SpaceInUser.current != nil{
            SpaceInUser.current!.movedToCoordinate(coordinate: location.coordinate)
        } else {
            SpaceInUser.current = SpaceInUser(name: "", email: "", uid: "")
            SpaceInUser.current?.movedToCoordinate(coordinate: location.coordinate)
        }
    }
}


//MARK: - Managers Setup
extension AppDelegate {
    fileprivate func setupManagers() {
        ReachabilityManager.setup()
        MediaManager.setup()
    }
}
