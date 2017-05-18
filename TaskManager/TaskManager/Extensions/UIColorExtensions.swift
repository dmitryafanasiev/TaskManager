//
//  UIColorExtensions.swift
//  TaskManager
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
    
    class func tmBlue() -> UIColor {
        return UIColor(hex: 0x019CFF)
    }
    
    class func tmBlueDisabled() -> UIColor {
        return UIColor(hex: 0x86D3FF)
    }
    
    class func tmBlueHighlited() -> UIColor {
        return UIColor(hex: 0x1069C6)
    }
    
    class func tmTurquoise() -> UIColor {
        return UIColor(hex: 0x60DAD2)
    }
    
    class func tmTurquoiseDark() -> UIColor {
        return UIColor(hex: 0x51D0C7)
    }
    
    class func tmPrimaryDarkGrey() -> UIColor {
        return UIColor(hex: 0x484745)
    }
    
    class func tmSecondaryMediumGrey() -> UIColor {
        return UIColor(hex: 0x969594)
    }
    
    class func tmTertiaryLightGrey() -> UIColor {
        return UIColor(hex: 0xCCCBCB)
    }
    
    class func tmLightGrey() -> UIColor {
        return UIColor(hex: 0xFAFAFA)
    }
    
    class func tmLightBackgroundGrey() -> UIColor {
        return UIColor(hex: 0xF5F5F5)
    }
    
}
