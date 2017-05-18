//
//  CoreDataTableViewController.swift
//  TaskManager
//

import UIKit
import CoreData

class CoreDataTableViewController: TableViewWithKeyboardViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchResultControllerWillChangeContent = { [weak self] in
            self?.tableView?.beginUpdates()
        }
        
        fetchResultControllerDidChangeContent = { [weak self] in
            self?.tableView?.endUpdates()
        }
        
        fetchResultControllerDidChangeObject = { [weak self] (object, indexPath, type, newIndexPath) in
            guard let strongSelf = self else {
                return
            }
            switch type {
            case .insert:
                if let newPath = newIndexPath {
                    strongSelf.tableView?.insertRows(at: [newPath], with: strongSelf.insertRowAnimation)
                }
                break
                
            case .delete:
                if let path = indexPath {
                    strongSelf.tableView?.deleteRows(at: [path], with: strongSelf.deleteRowAnimation)
                }
                break
                
            case .update:
                if let path = indexPath {
                    strongSelf.tableView?.reloadRows(at: [path], with: strongSelf.changeRowAnimation)
                }
                break
                
            case .move:
                if let path = indexPath {
                    strongSelf.tableView?.deleteRows(at: [path], with: strongSelf.moveRowAnimation)
                }
                if let newPath = newIndexPath {
                    strongSelf.tableView?.insertRows(at: [newPath], with: strongSelf.moveRowAnimation)
                }
                break
            }
        }
        
        fetchResultControllerDidChangeSection = { [weak self] (section, index, type) in
            guard let strongSelf = self else {
                return
            }
            
            switch type {
            case .insert:
                strongSelf.tableView?.insertSections(IndexSet(integer: index), with: strongSelf.insertRowAnimation)
                break
                
            case .delete:
                strongSelf.tableView?.deleteSections(IndexSet(integer: index), with: strongSelf.deleteRowAnimation)
                break
            default:
                break
            }
        }
    }
    
}
