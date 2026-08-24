//
//  Helper+UIView.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 08/10/25.
//

import Foundation
import UIKit

private var tapKey: UInt8 = 0

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
//            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func animShow(with value:CGFloat = 0){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],
                       animations: {
            self.center.y -= (self.bounds.height + value)
            self.layoutIfNeeded()
        }, completion: nil)
        self.isHidden = false
    }
    func animHide(with value:CGFloat = 0){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],
                       animations: {
            self.center.y += (self.bounds.height + value)
            self.layoutIfNeeded()
            
        },  completion: {(_ completed: Bool) -> Void in
            self.isHidden = true
        })
    }
    
    
    func fadeIn(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.5, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.5, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    
    func addGradient(_ colors: [UIColor], locations: [NSNumber], frame: CGRect = .zero) {
        
        // Create a new gradient layer
        let gradientLayer = CAGradientLayer()
        
        // Set the colors and locations for the gradient layer
        gradientLayer.colors = colors.map{ $0.cgColor }
        gradientLayer.locations = locations
        
        // Set the start and end points for the gradient layer
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        // Set the frame to the layer
        gradientLayer.frame = frame
        
        // Add the gradient layer as a sublayer to the background view
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // Add tap gesture
    
    func tap(action: @escaping () -> Void) {
        isUserInteractionEnabled = true
        
        // Store action using associated object
        objc_setAssociatedObject(self, &tapKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Remove previous gesture if already added
        if let gestures = gestureRecognizers {
            for g in gestures where g is UITapGestureRecognizer {
                removeGestureRecognizer(g)
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        if let action = objc_getAssociatedObject(self, &tapKey) as? () -> Void {
            action()
        }
    }
}
