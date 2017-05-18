//
//  ViewModel.swift
//  TaskManager
//

import Foundation

protocol ViewModelProtocol {
    func itemsCountForGroup(groupIndex : Int) -> Int
    func itemForGroup(groupIndex : Int, atPosition position : Int) -> AnyObject?
}

class ViewModel: ViewModelProtocol {
    
    private(set) var source = Array<Array<AnyObject>>()
    private(set) var sourceGroupKeys = Array<AnyObject>() // for handling section info
    
    func itemForGroup(groupIndex: Int, atPosition position: Int) -> AnyObject? {
        if source.count > groupIndex && source[groupIndex].count > position {
            return source[groupIndex][position]
        }
        print("\(String(describing: self)) error: trying to access out of bounds element at group \(groupIndex) and position \(position)")
        return nil
    }
    
    func appendElement(element: AnyObject, atGroup groupIndex : Int) {
        if source.count > groupIndex {
            source[groupIndex].append(element)
        } else if source.count == groupIndex {
            source.append(Array<AnyObject>())
            source[groupIndex].append(element)
        } else {
            print("\(String(describing: self)) error: trying to access out of bounds group \(groupIndex)")
        }
    }
    
    func addElement(element: AnyObject, atGroup groupIndex : Int, atPosition position: Int) {
        if source.count > groupIndex {
            if source[groupIndex].count > position {
                source[groupIndex][position] = element
            } else {
                print("\(String(describing: self)) error: trying to add out of bounds element \(groupIndex)")
            }
        } else if source.count == groupIndex {
            source.append(Array<AnyObject>())
            if position == 0 {
                source[groupIndex].append(element)
            } else {
                print("\(String(describing: self)) error: trying to add out of bounds element \(groupIndex) in empty array")
            }
        } else {
            print("\(String(describing: self)) error: trying to access out of bounds group \(groupIndex)")
        }
    }
    
    func removeAllElements(atGroup groupIndex : Int) {
        if source.count > groupIndex {
            source[groupIndex].removeAll()
        } else {
            print("\(String(describing: self)) error: trying to remove all elements in non-existing group \(groupIndex)")
        }
    }
    
    func clearAllData() {
        removeAllElements()
        removeAllGroupKeys()
    }
    
    func removeAllElements() {
        source.removeAll()
    }
    
    func removeAllGroupKeys() {
        sourceGroupKeys.removeAll()
    }
    
    func appendElements(elements: Array<AnyObject>, atGroup groupIndex: Int) {
        if source.count > groupIndex {
            source[groupIndex].append(contentsOf: elements)
        } else if source.count == groupIndex {
            source.append(Array<AnyObject>())
            source[groupIndex].append(contentsOf: elements)
        } else {
            print("\(String(describing: self)) error: trying to access out of bounds group \(groupIndex)")
        }
    }
    
    func groupKeyForGroup(index: Int) -> AnyObject? {
        if sourceGroupKeys.count > index {
            return sourceGroupKeys[index]
        } else {
            print("\(String(describing: self)) error: trying to access out of bounds group key \(index)")
            return nil
        }
    }
    
    func appendGroupKey(element: AnyObject) {
        sourceGroupKeys.append(element)
    }
    
    func appendGroupKeys(elements: Array<AnyObject>) {
        sourceGroupKeys.append(contentsOf: elements)
    }
    
    func itemsCountForGroup(groupIndex: Int) -> Int {
        if let items = itemsForGroup(groupIndex: groupIndex) {
            return items.count
        }
        return 0
    }
    
    func itemsForGroup(groupIndex: Int) -> [AnyObject]? {
        if source.count > groupIndex {
            return source[groupIndex]
        }
        print("\(String(describing: self)) error: trying to access out of bounds group \(groupIndex)")
        return nil
    }

}
