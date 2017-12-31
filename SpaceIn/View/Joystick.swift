
//
//  CDJoystick.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//
import UIKit

protocol JoystickDelegate : class{
    func joystickDataChanged(ToData data: CDJoystickData)
    func joystickCentered()
}

public struct CDJoystickData: CustomStringConvertible {
    
    /// (-1.0, -1.0) at bottom left to (1.0, 1.0) at top right
    public var velocity: CGPoint = .zero
    
    public var angle: CGFloat = 0.0
    
    public var description: String {
        return "velocity: \(velocity), angle: \(angle)"
    }
}

@IBDesignable
public class CDJoystick: UIView {
    
    @IBInspectable public var substrateColor: UIColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1) { didSet { setNeedsDisplay() }}
    @IBInspectable public var substrateBorderColor: UIColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1) { didSet { setNeedsDisplay() }}
    @IBInspectable public var substrateBorderWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() }}
    
    @IBInspectable public var stickSize: CGSize = CGSize(width: 50, height: 50) { didSet { setNeedsDisplay() }}
    @IBInspectable public var stickColor: UIColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1) { didSet { setNeedsDisplay() }}
    @IBInspectable public var stickBorderColor: UIColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1) { didSet { setNeedsDisplay() }}
    @IBInspectable public var stickBorderWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() }}
    
    @IBInspectable public var fade: CGFloat = 1.0 { didSet { setNeedsDisplay() }}
    
    public var trackingHandler: ((CDJoystickData) -> Void)?
    
    private var data = CDJoystickData()
    private var stickView = UIView(frame: .zero)
    private var displayLink: CADisplayLink?
    
    private var tracking = false {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.alpha = self.tracking ? 1.0 : self.fade
            }
        }
    }
    
    weak var delegate: JoystickDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        displayLink = CADisplayLink(target: self, selector: #selector(listen))
        displayLink?.add(to: .current, forMode: .commonModes)
        self.backgroundColor = UIColor.clear
    }
    
    public func listen() {
        guard tracking else { return }
        trackingHandler?(data)
    }
    
    public override func draw(_ rect: CGRect) {
        alpha = fade
        
        layer.backgroundColor = UIColor.clear.cgColor
        layer.borderColor = substrateBorderColor.cgColor
        layer.borderWidth = substrateBorderWidth
        layer.cornerRadius = bounds.width / 2
        
        
        stickView.frame = CGRect(origin: .zero, size: stickSize)
        stickView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        stickView.layer.backgroundColor = stickColor.cgColor
        stickView.layer.borderColor = stickBorderColor.cgColor
        stickView.layer.borderWidth = stickBorderWidth
        stickView.layer.cornerRadius = stickSize.width / 2
        
        if let superview = stickView.superview {
            superview.bringSubview(toFront: stickView)
        } else {
            addSubview(stickView)
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tracking = true
        
        UIView.animate(withDuration: 0.1) {
            //self.touchesMoved(touches, with: event)
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let centerXPosition = bounds.size.width / 2
        let centerYPosition = bounds.size.height / 2
        let userTouchPointInRelationToCenter = CGPoint(x: location.x - centerXPosition, y: centerYPosition - location.y)
        
        let hypoteneuse = sqrt(pow(userTouchPointInRelationToCenter.x, 2) + pow(userTouchPointInRelationToCenter.y, 2))
        
        let padding = self.padding()
        
        if hypoteneuse <= padding && hypoteneuse >= padding / 2 {
            let finalPoint = CGPoint(x: userTouchPointInRelationToCenter.x + centerXPosition, y: centerYPosition - userTouchPointInRelationToCenter.y)
            stickView.center = finalPoint
            self.setDataForPoint(point: userTouchPointInRelationToCenter)
            
        } else if hypoteneuse > padding {

            let bearingRadians = atan2(userTouchPointInRelationToCenter.y, userTouchPointInRelationToCenter.x)
            var bearingDegrees = bearingRadians * CGFloat((180.0 / M_PI))
            bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees))
            
            let sinOfTheta = sin(bearingRadians)
            
            let generatedY =  padding * sinOfTheta
            let generatedX = padding * cos(bearingRadians)
            
            let finalPoint = CGPoint(x: generatedX + centerXPosition, y: centerYPosition - generatedY)
            stickView.center = finalPoint
            self.setDataForPoint(point: CGPoint(x: generatedX, y: generatedY))
        }
    }
    
    fileprivate func setDataForPoint(point: CGPoint) {
        let x = clamp(point.x, lower: -bounds.size.width / 2, upper: bounds.size.width / 2) / (bounds.size.width / 2)
        let y = clamp(point.y, lower: -bounds.size.height / 2, upper: bounds.size.height / 2) / (bounds.size.height / 2)
        
        data = CDJoystickData(velocity: CGPoint(x: x, y: y), angle: atan2(x, y))
        self.delegate?.joystickDataChanged(ToData: data)

    }
    
    fileprivate func padding() -> CGFloat {
        let innerCircleHeight = self.stickView.frame.height
        let outerCircleHeight = self.frame.height
        
        return outerCircleHeight - self.substrateBorderWidth - innerCircleHeight - self.stickView.layer.borderWidth - self.layer.borderWidth - 5 
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        reset()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        reset()
    }
    
    private func reset() {
        tracking = false
        data = CDJoystickData()
        
        UIView.animate(withDuration: 0.25) {
            self.stickView.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        }
        self.delegate?.joystickCentered()
    }
    
    private func clamp<T: Comparable>(_ value: T, lower: T, upper: T) -> T {
        return min(max(value, lower), upper)
    }
}
