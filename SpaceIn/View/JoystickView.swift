//
//  JoystickView.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit

protocol JoystickViewDelegate: class {
    func tappedJoyStick()
}

class JoyStickView: UIView {
    
    let joyStick = UIButton(asConstrainable: false, frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    fileprivate var isExpanded = false
    
    weak var delegate: JoystickViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupJoystick()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var didSetupJoystick = false
    fileprivate static let joystickPaddingMultiplier: CGFloat = 0.30
}


//MARK: - Joystick
extension JoyStickView {
    
    fileprivate func setupJoystick() {
        guard didSetupJoystick == false else {
            return
        }
        
        joyStick.frame = joystickFrame()
        
        addSubview(joyStick)
        joyStick.translatesAutoresizingMaskIntoConstraints = true
        joyStick.backgroundColor = UIColor.white
        joyStick.layer.cornerRadius = joyStick.bounds.size.width * 0.5
        joyStick.clipsToBounds = true
        joyStick.addTarget(self, action: #selector(tappedJoyStick), for: .touchUpInside)
        setupJoystickGreenCircle()
        
        didSetupJoystick = true
    }
    
    private func joystickFrame() -> CGRect {
        let width = frame.width - frame.width * JoyStickView.joystickPaddingMultiplier
        let height = frame.height - frame.height * JoyStickView.joystickPaddingMultiplier
        
        let centerX = frame.width / 2
        let x = centerX - width / 2
        
        let centerY = frame.width / 2
        let y = centerY - height / 2
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func setupJoystickGreenCircle() {
//        self.joyStick.substrateBorderColor = UIColor.clear
//        self.joyStick.substrateBorderColor = UIColor.clear

        let greenCircleImage = UIImage(named: AssetName.greenCircle.rawValue)
        let imageView = UIImageView(image: greenCircleImage)
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.constrainPinInside(view: self)
        imageView.contentMode = .scaleAspectFill
        
        imageView.backgroundColor = UIColor.clear
    }
}

//MARK: - Tap
extension JoyStickView {
    @objc fileprivate func tappedJoyStick() {
        self.delegate?.tappedJoyStick()
    }
}
