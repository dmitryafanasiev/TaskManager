//
//  KeyboardViewController.swift
//  TaskManager
//

import UIKit

protocol KeyboardAppearanceProtocol {
    func keyboardWillAppear(notification : NSNotification)
    func keyboardDidAppear(notification : NSNotification)
    func keyboardWillHide(notification : NSNotification)
    func keyboardDidHide(notification : NSNotification)
}

class KeyboardViewController : CoreDataViewController, KeyboardAppearanceProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardViewController.keyboardWillAppear),
                                               name: .UIKeyboardDidShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardViewController.keyboardDidAppear),
                                               name: .UIKeyboardDidShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardViewController.keyboardWillHide),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardViewController.keyboardDidHide),
                                               name: .UIKeyboardDidHide,
                                               object: nil)
    }
    
    deinit  {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
    }
    
    func keyboardWillAppear(notification : NSNotification) {
        
    }
    
    func keyboardDidAppear(notification : NSNotification) {
        
    }
    
    func keyboardDidHide(notification : NSNotification) {
        
    }
    
    func keyboardWillHide(notification : NSNotification) {
        
    }
}
