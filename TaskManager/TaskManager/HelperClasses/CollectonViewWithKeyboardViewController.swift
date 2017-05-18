//
//  CollectonViewWithKeyboardViewController.swift
//  TaskManager
//

import UIKit

class CollectonViewWithKeyboardViewController: KeyboardViewController {
    @IBOutlet weak var collectionView : UICollectionView!
    var suggestedInsets = UIEdgeInsets.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.collectionView.endEditing(true)
    }
    
    override func keyboardWillHide(notification : NSNotification) {
        super.keyboardWillHide(notification: notification)
        
        collectionView.contentInset = UIEdgeInsets.zero
        collectionView.scrollIndicatorInsets = UIEdgeInsets.zero
        suggestedInsets = UIEdgeInsets.zero
    }
    
    override func keyboardWillAppear(notification : NSNotification) {
        super.keyboardWillAppear(notification: notification)
        
        guard let notificationObject = notification.userInfo else {
            return
        }
        if let endFrame = notificationObject[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let window = AppDelegate.sharedDelegate.window {
            
            let keyboardEndFrameOnWindow = endFrame.cgRectValue
            
            if let tableSuperview = collectionView.superview {
                let tableRectOnWindow = window.convert(collectionView.frame, from: tableSuperview)
                
                let height = keyboardEndFrameOnWindow.intersection(tableRectOnWindow).size.height
                
                if height >= 0 {
                    collectionView.contentInset = UIEdgeInsets(top: 0,
                                                      left: 0,
                                                      bottom: height,
                                                      right: 0)
                    
                    collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0,
                                                               left: 0,
                                                               bottom: height,
                                                               right: 0)
                    suggestedInsets = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: height,
                                                   right: 0)
                }
            }
        }
    }
}
