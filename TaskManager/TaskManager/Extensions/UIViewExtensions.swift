//
//  UIViewExtensions.swift
//  TaskManager
//

import UIKit

extension UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set(newValue) {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set(newValue) {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    static var defaultReuseIdentifier : String {
        return String(describing: self)
    }
    
    func changeConstraintsWithIdentifier(id: String, toConstant constant: CGFloat) {
        let itemConstraints = constraints.filter { $0.identifier == id }
        itemConstraints.forEach { $0.constant = constant }
    }
    
    func roundView(radius: CGFloat) {
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.cornerRadius = radius
    }
    
}
