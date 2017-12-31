//
//  AskLocationVC.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit

protocol AskLocationVCDelegate {
    func finishedLocationAskingForVc(vc: AskLocationVC)
}

// MARK: - Lifecycle
class AskLocationVC: UIViewController {
    
    var delegate: AskLocationVCDelegate?
    
    fileprivate let brokenPinView = UIImageView(image: UIImage(named: AssetName.brokenPin.rawValue), asConstrainable: true)
    fileprivate let okayButtom = RoundedButton(filledIn: false, color: UIColor.white)
    fileprivate let explanationLabel = UILabel(asConstrainable: true, frame: CGRect.zero)
    fileprivate let gradientView = UIImageView(image: UIImage(named: AssetName.spaceinGradient.rawValue), asConstrainable: true)
    
    fileprivate var didSetupView = false
    fileprivate var weAreWaitingForLocationManager = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeSureWeDontAlreadyHaveTheUsersLocationPermissions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}

// MARK: - UI
extension AskLocationVC {
    
    fileprivate func setupView() {
        if !self.didSetupView {
            self.didSetupView = true
            self.setupSubviews()
            self.addSubviews()
            self.constrainSubviews()
        }
    }
    
    private func setupSubviews() {
        self.gradientView.contentMode = .scaleToFill
        self.brokenPinView.contentMode = .scaleAspectFit
        
        self.explanationLabel.text = SpaceinCopy.locationPermissionViewBottomText.rawValue
        self.explanationLabel.font = StyleGuideManager.sharedInstance.askLocationViewFont()
        self.explanationLabel.textColor = UIColor.white
        self.explanationLabel.textAlignment = .center
        self.explanationLabel.lineBreakMode = .byWordWrapping
        self.explanationLabel.numberOfLines = 2
        self.explanationLabel.minimumScaleFactor = 0.75
        self.explanationLabel.adjustsFontSizeToFitWidth = true
        
        self.okayButtom.setTitle("Okay", for: .normal)
        self.okayButtom.titleLabel?.font = StyleGuideManager.sharedInstance.askLocationViewFont()
        self.okayButtom.addTarget(self, action: #selector(self.okayPressed), for: .touchUpInside)
    }
    
    private func addSubviews() {
        self.view.addSubview(self.gradientView)
        self.view.addSubview(self.brokenPinView)
        self.view.addSubview(self.okayButtom)
        self.view.addSubview(self.explanationLabel)
    }
    
    private func constrainSubviews() {
        self.constrainGradientView()
        self.constrainPinView()
        self.constrainExplanationLabel()
        self.constrainOkayButton()
    }
    
    private func constrainGradientView() {
        self.gradientView.constrainPinInside(view: self.view)
    }
    
    private func constrainPinView() {
        self.brokenPinView.translatesAutoresizingMaskIntoConstraints = false
        self.brokenPinView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.brokenPinView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40).isActive = true
        
        //width = 3/4 height
        let height = self.view.frame.height / 6.9
        self.brokenPinView.constrainToHeight(height: height)
        self.brokenPinView.constrainToWidth(width: height * 0.75)
    }
    
    private func constrainExplanationLabel() {
        self.explanationLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
        
        let sidePadding = CGFloat(20)
        self.explanationLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: sidePadding).isActive = true
        self.explanationLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -sidePadding).isActive = true
        
        self.explanationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func constrainOkayButton() {
        self.okayButtom.translatesAutoresizingMaskIntoConstraints = false
        self.okayButtom.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.okayButtom.topAnchor.constraint(equalTo: self.brokenPinView.bottomAnchor, constant: 70).isActive = true
        self.okayButtom.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.okayButtom.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.70).isActive = true
    }
    
    
}

// MARK: - Functionality
extension AskLocationVC {
    func okayPressed() {
        
        
        
        self.askForLocationPermission()
        self.setupOnesignal()
    }
    // MARK: onesignal
    
    func setupOnesignal() {
        NotificationCenter.default.post(name: .SetupOneSignal, object: nil)
    }
}





// MARK:- Location
extension AskLocationVC {
    
    fileprivate func makeSureWeDontAlreadyHaveTheUsersLocationPermissions() {
        let status = LocationManager.sharedInstance.userLocationStatus()
        if status == .authorized {
            self.addObserversForLocationManager()
            LocationManager.sharedInstance.startTrackingUser()
        } else if status == .denied {
            self.delegate?.finishedLocationAskingForVc(vc: self)
        }
    }
    
    fileprivate func askForLocationPermission() {
        
        let locationPermissionStatus = LocationManager.sharedInstance.userLocationStatus()
        
        if locationPermissionStatus == .authorized {
            self.addObserversForLocationManager()
            LocationManager.sharedInstance.startTrackingUser()
        } else if locationPermissionStatus == .unknown {
            self.addObserversForLocationManager()
            LocationManager.sharedInstance.requestUserLocation()
        } else {
            //it is denied or other so we should pull out
            self.delegate?.finishedLocationAskingForVc(vc: self)
        }
    }
    
    
    fileprivate func addObserversForLocationManager() {
        self.weAreWaitingForLocationManager = true
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.userLocationSet), name: .didSetUserLocation, object: nil)
        nc.addObserver(self, selector: #selector(self.userLocationDeniedOrRestricted), name: .deniedLocationPermission, object: nil)
        nc.addObserver(self, selector: #selector(self.userLocationDeniedOrRestricted), name: .restrictedLocationPermission, object: nil)
    }
    
    private func removeLocationManagerObservers() {
        self.weAreWaitingForLocationManager = false
        
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: .didSetUserLocation, object: nil)
        nc.removeObserver(self, name: .deniedLocationPermission, object: nil)
        nc.removeObserver(self, name: .restrictedLocationPermission, object: nil)
        
    }
    
    func userLocationSet() {
        self.removeLocationManagerObservers()
        self.delegate?.finishedLocationAskingForVc(vc: self)
    }
    
    func userLocationDeniedOrRestricted() {
        self.removeLocationManagerObservers()
        self.delegate?.finishedLocationAskingForVc(vc: self)
    }
}
