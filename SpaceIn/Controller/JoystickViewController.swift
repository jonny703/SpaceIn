//
//  JoystickViewController.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit

protocol JoyStickVCDelegate: class {
    func tappedLocatedMe()
    func joyStickVCTappedZoomButton(zoomIn: Bool)
}


class JoystickViewController: UIViewController {
    let joyStickView = JoyStickView(frame: CGRect.zero)

    fileprivate let threeDButton = RoundedButton(filledIn: false, color: UIColor.white)
    fileprivate let minusButton = RoundedButton(filledIn: false, color: UIColor.white)
    fileprivate let plusButton = RoundedButton(filledIn: false, color: UIColor.white)
    fileprivate let notificationsButton = RoundedButton(filledIn: false, color: UIColor.white)
    fileprivate let profileContainerButton = RoundedButton(filledIn: false, color: UIColor.white)
    fileprivate let profileButton = RoundedButton(filledIn: false, color: UIColor.clear) //for profile pictures the padding between the border and the image isn't happening so we have to wrap it in a circular view
    fileprivate let locateMeButton = UIButton(type: .custom)
    
    fileprivate var didSetup = false
    fileprivate var isShowingButtons = false
    weak var delegate: JoyStickVCDelegate?
    
    static let paddingFromJoystick: CGFloat = 12
    static let joystickMiniButtonMultiplier: CGFloat = 0.55
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
        
    }
    
    fileprivate static let animationDuration = 0.3
}

///MARK:- User Interaction
extension JoystickViewController: JoystickViewDelegate {
    func tappedJoyStick() {
        showButtons(show: !isShowingButtons)
        print("we tapped the joystick")
    }
    
    func tappedLocateMe() {
        delegate?.tappedLocatedMe()
    }
    
    fileprivate func showButtons(show: Bool) {
        if didSetup { //so we don't call this in the initialization
            joyStickView.isUserInteractionEnabled = false
            
            if isShowingButtons {
                UIView.animate(withDuration: 0.5, animations: {
                    self.hideAndDisableButtons()
                }, completion: { [weak self] done in
                    self?.joyStickView.isUserInteractionEnabled = true
                    self?.isShowingButtons = false
                })
            } else {
                UIView.animate(withDuration: JoystickViewController.animationDuration, animations: {
                    self.showAndEnableButtons()
                }, completion: { [weak self] done in
                    self?.joyStickView.isUserInteractionEnabled = true
                    self?.isShowingButtons = true
                })
            }
            
            self.joyStickView.isUserInteractionEnabled = true
        }
    }
}


//MARK: - UI Setup
extension JoystickViewController {
    fileprivate func setup() {
        if didSetup == false {
            didSetup = true
            setupJoystick()
            setupButtons()
            didSetup = true
        }
    }
    
    private func setupJoystick() {
        view.addSubview(joyStickView)
        joyStickView.constrainWidthAndHeightToValueAndActivate(value: 80)
        joyStickView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joyStickView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        joyStickView.delegate = self
    }
    
    private func setupButtons() {
        for button in buttons() {
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
        }
        
        layoutButtons()
    }
    
    private func layoutButtons() {
        constrainThreeDButton()
        setupProfileButton()
        constrainNotificationsButton()
        setupPlusAndMinusButtons()
        setupLocateMeButton()
        hideAndDisableButtons()
    }
    

    fileprivate func hideAndDisableButtons() {
        profileContainerButton.alpha = 0
        profileButton.alpha = 0
        minusButton.alpha = 0
        plusButton.alpha = 0
        notificationsButton.alpha = 0
        threeDButton.alpha = 0
        
        profileContainerButton.isUserInteractionEnabled = false
        profileButton.isUserInteractionEnabled = false
        minusButton.isUserInteractionEnabled = false
        plusButton.isUserInteractionEnabled = false
        notificationsButton.isUserInteractionEnabled = false
        threeDButton.isUserInteractionEnabled = false
    }
    
    fileprivate func showAndEnableButtons() {
        profileContainerButton.alpha = 1
        profileButton.alpha = 1
        minusButton.alpha = 1
        plusButton.alpha = 1
        notificationsButton.alpha = 1
        threeDButton.alpha = 1
        
        profileContainerButton.isUserInteractionEnabled = true
        profileButton.isUserInteractionEnabled = true
        minusButton.isUserInteractionEnabled = true
        plusButton.isUserInteractionEnabled = true
        notificationsButton.isUserInteractionEnabled = true
        threeDButton.isUserInteractionEnabled = true
    }
    
    private func constrainNotificationsButton() {
        let notificationImage = UIImage(named: AssetName.notification.rawValue)
        setupRounded(button: notificationsButton, withImage: notificationImage)
        notificationsButton.centerYAnchor.constraint(equalTo: threeDButton.centerYAnchor).isActive = true
        notificationsButton.leftAnchor.constraint(equalTo: joyStickView.rightAnchor, constant: JoystickViewController.paddingFromJoystick * 2).isActive = true
    }
    
    private func setupPlusAndMinusButtons() {
        let plusImage = UIImage(named: AssetName.zoomIn.rawValue)
        let minusImage = UIImage(named: AssetName.zoomOut.rawValue)

        setupRounded(button: plusButton, withImage: plusImage)
        setupRounded(button: minusButton, withImage: minusImage)

        plusButton.centerYAnchor.constraint(equalTo: joyStickView.topAnchor, constant: -JoystickViewController.paddingFromJoystick / 2).isActive = true
        minusButton.centerYAnchor.constraint(equalTo: joyStickView.topAnchor, constant: -JoystickViewController.paddingFromJoystick / 2).isActive = true
        
        plusButton.rightAnchor.constraint(equalTo: notificationsButton.centerXAnchor, constant: -5).isActive = true
        minusButton.leftAnchor.constraint(equalTo: threeDButton.centerXAnchor, constant: 5).isActive = true
        
        let plusLongGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(plusPressedDown(withSender:)))
        plusLongGestureRecognizer.allowableMovement = 15
        plusLongGestureRecognizer.minimumPressDuration = 0.25
        
        let minusLongGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(minusPressedDown))
        minusLongGestureRecognizer.allowableMovement = 15
        minusLongGestureRecognizer.minimumPressDuration = 0.25
        
        plusButton.addGestureRecognizer(plusLongGestureRecognizer)
        minusButton.addGestureRecognizer(minusLongGestureRecognizer)
        
    }
    
    private func setupLocateMeButton() {
        locateMeButton.centerYAnchor.constraint(equalTo: notificationsButton.centerYAnchor).isActive = true
        locateMeButton.widthAnchor.constraint(equalTo: plusButton.widthAnchor).isActive = true
        locateMeButton.heightAnchor.constraint(equalTo: plusButton.heightAnchor).isActive = true
        locateMeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        
        locateMeButton.setTitle("", for: .normal)
        locateMeButton.setImage(UIImage(named: AssetName.locationIcon.rawValue), for: .normal)
        locateMeButton.imageView?.contentMode = .scaleAspectFit
        
        locateMeButton.addTarget(self, action: #selector(tappedLocateMe), for: .touchUpInside)
    }
    
    private func constrainThreeDButton() {
        //setup one button
        let threeDImage = UIImage(named: AssetName.threeDCircle.rawValue)
        setupRounded(button: threeDButton, withImage: threeDImage)
        threeDButton.rightAnchor.constraint(equalTo: joyStickView.leftAnchor, constant: -JoystickViewController.paddingFromJoystick * 2).isActive = true
        threeDButton.centerYAnchor.constraint(equalTo: joyStickView.centerYAnchor, constant: 5).isActive = true
    }
    
    private func setupProfileButton() {
        profileContainerButton.isUserInteractionEnabled = false
        profileContainerButton.translatesAutoresizingMaskIntoConstraints = false
        profileContainerButton.titleLabel?.text = ""
        profileContainerButton.backgroundColor = UIColor.clear
        view.addSubview(profileContainerButton)
        setupRounded(button: profileContainerButton, withImage: nil)
        profileContainerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileContainerButton.bottomAnchor.constraint(equalTo: joyStickView.topAnchor, constant: -JoystickViewController.paddingFromJoystick - 5).isActive = true
        
        
        let profileImage = UIImage(named: AssetName.profilePlaceholder.rawValue)
        profileButton.setImage(profileImage, for: .normal)
        profileButton.imageView?.contentMode = .scaleAspectFit
        
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

        button.widthAnchor.constraint(equalTo: joyStickView.widthAnchor, multiplier: JoystickViewController.joystickMiniButtonMultiplier).isActive = true
        button.heightAnchor.constraint(equalTo: joyStickView.heightAnchor, multiplier: JoystickViewController.joystickMiniButtonMultiplier).isActive = true
    }
    
    //convenience function
    private func buttons() -> [UIButton] {
        return [threeDButton, minusButton, plusButton, notificationsButton, locateMeButton] //does not include profile button because it is setup a little differently
    }
}


//Mark: - Button Targets
extension JoystickViewController {
    @objc fileprivate func plusPressedDown(withSender sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
           delegate?.joyStickVCTappedZoomButton(zoomIn: true)            
        default:
            break
        }
    }
    
    @objc fileprivate func minusPressedDown() {
        delegate?.joyStickVCTappedZoomButton(zoomIn: false)
    }
}

