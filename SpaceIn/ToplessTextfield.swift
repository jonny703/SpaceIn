//
//  ToplessTextfield.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//
//

//        let testTextfield = ToplessTextField(frame: CGRect(x: 20, y: 20, width: 100, height: 60))
//        self.view.addSubview(testTextfield)
//******** the above has the line in the right place. We ay need to make the y a calculated value

import UIKit

protocol ToplessTextFieldDelegate {
    func didDismissKeyboard(textField: ToplessTextField)
    func toplessTextFieldDidBeginEditing()
    func toplessTextFieldDidEndEdting()
}

class ToplessTextField: UITextField, UITextFieldDelegate {
    
    private var didAddBottom = false
    var toplessTextfieldDelegate: ToplessTextFieldDelegate?
    
    var borderColor : UIColor = .clear {
        didSet {
            if self.border != nil {
                self.border!.borderColor = borderColor.cgColor
            }
        }
    }
    
    var selectedBorderColor: UIColor?
    
    private var border: CALayer?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.borderStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.frame != CGRect.zero {
            self.addBottom()
        }
    }
    
    func addBottom() {
        if !self.didAddBottom {
            self.border = CALayer()
            let width = CGFloat(2)
            self.border!.borderColor = borderColor.cgColor
            self.border!.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: width)
            self.border!.borderWidth = width
            self.layer.addSublayer(border!)
            self.layer.masksToBounds = true
            self.didAddBottom = true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.selectedBorderColor != nil {
            self.border?.borderColor = self.selectedBorderColor!.cgColor
        }
        self.toplessTextfieldDelegate?.toplessTextFieldDidBeginEditing()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.toplessTextfieldDelegate?.didDismissKeyboard(textField: self)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.border?.borderColor = self.borderColor.cgColor
        self.toplessTextfieldDelegate?.toplessTextFieldDidEndEdting()
    }
    
}
