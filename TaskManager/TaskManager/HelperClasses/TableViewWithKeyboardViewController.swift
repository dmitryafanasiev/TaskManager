//
//  TableViewWithKeyboardViewController.swift
//  TaskManager
//

import UIKit

class TableViewWithKeyboardViewController : KeyboardViewController {
    @IBOutlet weak var tableView : UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView?.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tableView?.endEditing(true)
    }
    
    override func keyboardWillHide(notification : NSNotification) {
        super.keyboardWillHide(notification: notification)
        
        tableView?.contentInset = UIEdgeInsets.zero
        tableView?.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    override func keyboardWillAppear(notification : NSNotification) {
        super.keyboardWillAppear(notification: notification)
        
        guard let notificationObject = notification.userInfo else {
            return
        }
        if let endFrame = notificationObject[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let tableViewFrame = tableView?.frame,
            let table = tableView,
            let window = AppDelegate.sharedDelegate.window {
            
            let keyboardEndFrameOnWindow = endFrame.cgRectValue
            
            if let tableSuperview = table.superview {
                let tableRectOnWindow = window.convert(tableViewFrame, from: tableSuperview)
                
                let height = keyboardEndFrameOnWindow.intersection(tableRectOnWindow).size.height
                
                if height >= 0 {
                    table.contentInset = UIEdgeInsets(top: 0,
                                                      left: 0,
                                                      bottom: height,
                                                      right: 0)
                    
                    table.scrollIndicatorInsets = UIEdgeInsets(top: 0,
                                                               left: 0,
                                                               bottom: height,
                                                               right: 0)
                }
            }
        }
    }
}
