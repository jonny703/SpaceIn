//
//  MapView.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import MapKit
import Firebase

// moving anos http://stackoverflow.com/questions/8564013/animate-removal-of-annotations/8564097#8564097

//http://stackoverflow.com/questions/29776549/animate-mapkit-annotation-coordinate-change-in-swift

enum MapViewZoomType {
    case zoomedIn
    case zoomedOut
    case leaveAlone
    case defaultType
    case rotate
    
}

// MARK: - API
extension MapView {
    func setToLocation(location: CLLocation, zoomType: MapViewZoomType, animated: Bool) {
        self._setToLocation(location: location, zoomType: zoomType, animated: animated)
    }
    
    func isIn3DMode() -> Bool {
        return camera.pitch != 0
    }
    
    func reloadUserAnnotationIfNeeded() {
        _reloadUserAnnotationIfNeeded()
    }
}

// MARK: - Map View Delegate
protocol MapViewDelegate {
    func centerChangedToCoordinate(coordinate: CLLocationCoordinate2D)
}


// MARK: - Initialization and Lifecycle
class MapView: MKMapView {
    
    var mapViewController: MapViewController?
    
    //MARK: - Static vars/Lets
    static let defaultDistance: CLLocationDistance = 650
    static let defaultPitch: CGFloat = 65
    static let defaultHeading = 0.0
    static let zoomedOutAltitiude: CLLocationDistance =  50000000
    
    
    
    //MARK: - Instance vars/lets
    var mapViewDelagate: MapViewDelegate?
    fileprivate var coordinate = CLLocationCoordinate2D(latitude: 41.8902,longitude:  12.4922) {
        didSet {
            self.mapViewDelagate?.centerChangedToCoordinate(coordinate: self.coordinate)
        }
    }
    
    var userAnnotation: MKPointAnnotation?
    var didFinishLoadingMap = false
    var shouldRemoveUserPinOnMovement = true


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        mapType = .hybridFlyover
        showsPointsOfInterest = true
        showsTraffic = true
        showsCompass = false
        delegate = self
    }
    
    private func setUserInteraction() {
        self.isZoomEnabled = true
        self.isRotateEnabled = true
        self.isScrollEnabled = true
    }
    
    deinit {
        print("testing")
    }
}


// MARK: - Private
extension MapView {
    fileprivate func _setToLocation(location: CLLocation, zoomType: MapViewZoomType, animated: Bool) {
        self.coordinate = location.coordinate
        self.setCameraWithZoomTypeOnceCoordinateIsSet(zoomType: zoomType)
        self.setCenter(self.coordinate, animated: animated)
        self.setupUserPinBasedOnZoomType(zoomType: zoomType)
        print("we finished set to location")

    }
}

// MARK: - Map Setup & Manipulation - Private
extension MapView {
    fileprivate func addPin(pin: MKPointAnnotation) {
        self.addAnnotation(pin)
    }
    
    fileprivate func removePin(pin: MKPointAnnotation) {
        self.removeAnnotation(pin)
    }
}


//MARK: - User Location
extension MapView {
    public func addUserPin(withCoordinate coordinate: CLLocationCoordinate2D) {
        guard SpaceInUser.current != nil else {
            return
        }
        
        if self.userAnnotation == nil {
            self.userAnnotation = SpaceinUserAnnotation(withUser: SpaceInUser.current!, coordinate: coordinate)
        }
        
        self.userAnnotation!.coordinate = coordinate
        self.addPin(pin: self.userAnnotation!)
        
    }
    
    public func addOtherUsersPin(withUser user: SpaceUser, withCoordinate coordinate: CLLocationCoordinate2D) {
        
        let annotation = SpaceUserAnnotation(withUser: user, coordinate: coordinate)
        annotation.coordinate = coordinate
        self.addPin(pin: annotation)
        
    }
    
    public func removeOtherUsersPin() {
        
        self.removeAnnotations(self.annotations)
    
    }

    
    
    
    fileprivate func zoomToUserPin() {
        if self.userAnnotation != nil {
            let location = CLLocation(latitude: self.userAnnotation!.coordinate.latitude, longitude: self.userAnnotation!.coordinate.longitude)
            self.zoomInToUserAnnotationWithOverTheTopView()
            self.removeUserPin()
            
            
            //we have to wait for the zoom to finish before rotating the camera
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                UIView.animate(withDuration: 1.0, animations: {
                    //this rotates the camera
                    self._setToLocation(location: location, zoomType: .rotate, animated: true)
                })
            })
            
        }
    }
    
    fileprivate func zoomToCurrentUserPin() {
//        let location = CLLocation(latitude: Global.currentUserLocation.coordinate.latitude, longitude: Global.currentUserLocation.coordinate.longitude)
        
        let location = self.userLocation.location
        self.zoomInToUserAnnotationWithOverTheTopView()
        
        
        //we have to wait for the zoom to finish before rotating the camera
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            UIView.animate(withDuration: 1.0, animations: {
                //this rotates the camera
                self._setToLocation(location: location!, zoomType: .rotate, animated: true)
            })
        })
    }

    
    fileprivate func zoomInToUserAnnotationWithOverTheTopView() {
        let span = MKCoordinateSpanMake(0.01, 0.01)
//        MKCoordinateSpan(latitudeDelta: <#T##CLLocationDegrees#>, longitudeDelta: <#T##CLLocationDegrees#>)
        let region = MKCoordinateRegion(center: self.userLocation.coordinate, span: span)
        self.setRegion(region, animated: true)
    }
    
    public func removeUserPin() {
        if self.userAnnotation != nil {
            self.removePin(pin: self.userAnnotation!)
            self.userAnnotation = nil
        }
    }
    
    public func _reloadUserAnnotationIfNeeded() {
        guard let visibleUserAnnotation = self.userAnnotation else {
            return
        }
        
        let coordinate = visibleUserAnnotation.coordinate
        self.removeUserPin()
//        self.addUserPin(withCoordinate: coordinate)
    }
    
    fileprivate func setupUserPinBasedOnZoomType(zoomType: MapViewZoomType) {
        
        if zoomType == .zoomedOut {
//            self.addUserPin(withCoordinate: self.coordinate)
        } else if zoomType != .leaveAlone{
            self.removeUserPin()
        }
    }
    
    func viewIsUserAnnotaionView(view: MKAnnotationView) -> Bool{
        return view.annotation?.coordinate.latitude == self.userAnnotation?.coordinate.latitude && view.annotation?.coordinate.longitude == self.userAnnotation?.coordinate.longitude
    }

}


// MARK: - Camera
extension MapView {
    fileprivate func setCameraWithZoomTypeOnceCoordinateIsSet(zoomType: MapViewZoomType) {
        self.setCamera(self.cameraForZoomType(zoomType: zoomType), animated: true)
    }
    
    fileprivate func cameraForZoomType(zoomType: MapViewZoomType) -> MKMapCamera {
        switch zoomType {
        case .leaveAlone:
            return self.camera
        case .defaultType :
            return self.defaultCamera()
        case .zoomedIn:
            return self.zoomedInCamera()
        case .zoomedOut:
            return self.zoomedOutCamera()
        case .rotate:
            return self.rotatedCamera()
        }
    }
    
    fileprivate func defaultCamera() -> MKMapCamera {
        return MKMapCamera(lookingAtCenter: coordinate , fromDistance: MapView.defaultDistance, pitch: MapView.defaultPitch, heading: MapView.defaultHeading)
    }
    
    fileprivate func zoomedInCamera() -> MKMapCamera {
        return MKMapCamera(lookingAtCenter: coordinate, fromDistance: MapView.defaultDistance, pitch: MapView.defaultPitch, heading: MapView.defaultHeading)
    }
    
    fileprivate func zoomedOutCamera() -> MKMapCamera {
        return MKMapCamera(lookingAtCenter: self.coordinate, fromEyeCoordinate: self.coordinate, eyeAltitude: MapView.zoomedOutAltitiude)
    }
    
    fileprivate func rotatedCamera() -> MKMapCamera {
        return MKMapCamera(lookingAtCenter: self.centerCoordinate, fromDistance: self.camera.altitude, pitch: MapView.defaultPitch, heading: MapView.defaultHeading)
    }
}


// MARK: - Mapview Delegate
extension MapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 1. we check if it is the user annotation and if so return nil
        if annotation is MKUserLocation {
            return nil
        }
        
        guard let userAnnotation = annotation as? SpaceUserAnnotation else {
            return nil
        }
        
        //2. get the identifier for the annotation
        //3. if the view exists, return it
        
        
//        if let viewToReturn = mapView.dequeueReusableAnnotationView(withIdentifier: userAnnotation.uid) as? UserAnnotationView {
//            if let userPicture = userAnnotation.user.image {
//                viewToReturn.pictureView.image = userPicture
//            }
//            
//            viewToReturn.annotation = annotation
//            return viewToReturn
//        } else {  //4. Else, create the view
//            let annotationView = UserAnnotationView(annotation: userAnnotation, user: userAnnotation.user)
//            return annotationView
//            //start here and actually add one of the user annotation types and test this code
//        }
        
        var annotationView: MKAnnotationView?
        
        if SpaceInUser.userIsLoggedIn() {
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return nil
            }
            
            if uid == userAnnotation.user.userId {
                annotationView = SpaceUserAnnotationView(annotation: userAnnotation, user: userAnnotation.user, mapProfileName: AssetName.transparentPin.rawValue)
                annotationView?.canShowCallout = false

            } else {
                if userAnnotation.user.postCount != 0 {
                    annotationView = SpaceUserAnnotationView(annotation: userAnnotation, user: userAnnotation.user, mapProfileName: AssetName.mapProfileIcon.rawValue)
                } else {
                    annotationView = SpaceUserAnnotationView(annotation: userAnnotation, user: userAnnotation.user, mapProfileName: AssetName.transparentPin.rawValue)
                }
                annotationView?.isDraggable = true
                annotationView?.canShowCallout = false
//
//                let drag = UILongPressGestureRecognizer(target: self.mapViewController, action: #selector(self.lognPressed(gesture:)))
//                drag.minimumPressDuration = 0.3
//                drag.delegate = self.mapViewController
//                annotationView?.addGestureRecognizer(drag)
                
            }
            
        } else {
//            guard let userAnnotation = annotation as? SpaceUserAnnotation else {
//                return nil
//            }
//            annotationView = SpaceUserAnnotationView(annotation: userAnnotation, user: userAnnotation.user, mapProfileName: AssetName.transparentPin.rawValue)
        }
        
        
        return annotationView
        
    }
    
    func lognPressed(gesture: UILongPressGestureRecognizer) {
        print("longPressed")
    }
    
    fileprivate func resizedProfileImagesWith(image: UIImage, size: CGSize) -> UIImage {
        
        
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.didFinishLoadingMap && self.shouldRemoveUserPinOnMovement {
            self.removeOtherUsersPin()
            self.coordinate = self.centerCoordinate
            NotificationCenter.default.post(name: .FetchUsers, object: nil)
            
            let center = mapView.centerCoordinate
            
            let distance = self.getRadius(centerCoordinate: center) / 1000
            Global.currentDistance = distance
            if distance > 4000.0 {
                Global.currentDistance = 4000.0
            }
            
            print("dragMapDelegate")
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        if self.region.span.latitudeDelta < 0.01 || self.region.span.longitudeDelta < 0.01 {
            var region = self.region
            region.span = MKCoordinateSpanMake(0.01, 0.01)
            self.region = region
            self.setRegion(region, animated: false)
        }
        
    }
    
    
    private func turnOffFlyoverIfWeAreZoomedInTooMuch() {
        if camera.altitude < 1500 {
            self.mapType = .satellite
        } else {
            self.mapType = .satelliteFlyover
        }
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if self.didFinishLoadingMap == false {
            self.didFinishLoadingMap = true
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("we called did select annotation")
        
        
        
        if let annotationView = view as? SpaceUserAnnotationView {
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            if uid == annotationView.user?.userId {
                
                self.zoomToCurrentUserPin()
                
            } else {
                self.mapViewController?.presentUserProfileVC(user: annotationView.user!)
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        print("dragged", newState.rawValue)
        
        if let annotationView = view as? SpaceUserAnnotationView {
            
            if newState == .starting {
                print("dragStart")
                
                annotationView.dragState = .canceling
//                annotationView.dragState = .none
                
//                self.mapViewController?.presentPostHistoryController(user: annotationView.user!)
                
            } else if newState == .ending || newState == .canceling {
                self.mapViewController?.presentPostHistoryController(user: annotationView.user!)

                annotationView.dragState = .none
                print("dragEnd")
            }
        }
    }
    
    
}

//MARK: call post history controller

extension MapView {
    
    
    
}



//MARK: calculate radius

extension MapView {
    
    fileprivate func getRadius(centerCoordinate: CLLocationCoordinate2D) -> Double {
        
        let center = centerCoordinate
        
        let centerCoor = self.getCenterCoordinate()
        let centerLocation = CLLocation(latitude: centerCoor.latitude, longitude: centerCoor.longitude)
        var topCenterCoor = self.getTopCenterCoordinate()
        
        if topCenterCoor.latitude >= 90 {
            topCenterCoor.latitude = 90
        } else if topCenterCoor.latitude <= -90 {
            topCenterCoor.latitude = -90
        }
        if topCenterCoor.longitude >= 180 {
            topCenterCoor.longitude = 180
        } else if topCenterCoor.longitude <= -180 {
            topCenterCoor.longitude = -180
        }
        
        
        
        let topCenterLocation = CLLocation(latitude: topCenterCoor.latitude, longitude: topCenterCoor.longitude)
        
        let radius = centerLocation.distance(from: topCenterLocation)
        
        Global.currentCenterLocation = centerLocation
        
        return radius
    }
    
    fileprivate func getCenterCoordinate() -> CLLocationCoordinate2D {
        return self.centerCoordinate
    }
    
    fileprivate func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        
        let point = CGPoint(x: self.frame.size.width / 2.0, y: 0)
//        let point = CGPoint(x: 0, y: self.frame.size.height / 2.0)
        return self.convert(point, toCoordinateFrom: self)
    }
    
}














