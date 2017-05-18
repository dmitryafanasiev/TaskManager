//
//  FoundationExtenstions.swift
//  TaskManager
//

import Foundation

extension Array where Element: Equatable  {
    
    mutating func removeObject(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
    
    mutating func removeObjects(objects: [Element]) {
        for object in objects {
            removeObject(object: object)
        }
    }
    
}

extension Date {
    
    func tmDateFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: self)
    }
    
    func tmShortDateFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        return formatter.string(from: self)
    }
}

extension Int {
    
    func decimalStyleString() -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        return fmt.string(from: NSNumber(value: abs(self)))!
    }
    
}
