//
//  RoundedButton.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import QuartzCore

class RoundedButton: UIButton {
    private var color: UIColor?
    private var filledIn: Bool?
    var borderWidth: CGFloat = 2
    
    convenience init(filledIn: Bool, color: UIColor? ) {
        self.init(frame: CGRect.zero)
        self.filledIn = filledIn
        self.color = color
        self.setTitleColor(UIColor.gray, for: .highlighted)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.frame != CGRect.zero {
            self.layer.cornerRadius = self.frame.height * 0.5
            self.clipsToBounds = true
            self.setupColors()
        }
    }
    
    private func setupColors() {
        self.backgroundColor = self.filledIn == true ? self.color : UIColor.clear
        self.layer.borderWidth = self.filledIn == true ? 0 : borderWidth
        self.layer.borderColor = self.filledIn == true ? UIColor.clear.cgColor : self.color?.cgColor
    }
    
    func setFilledInState(filledIn: Bool) {
        self.filledIn = filledIn
        self.setupColors()
    }
}
