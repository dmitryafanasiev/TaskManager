//
//  TMProjectCell.swift
//  TaskManager
//

import Foundation
import UIKit

protocol TMProjectCustomizationProtocol {
    func customizeWithProject(project: TMProject?)
}

class TMProjectCell: UICollectionViewCell, TMProjectCustomizationProtocol {
    @IBOutlet weak private var projectNameLabel: UILabel!
    @IBOutlet weak private var tasksCountLabel: UILabel!
    @IBOutlet weak private var selectionView: UIView!
    
    var projectName: String? {
        didSet {
            projectNameLabel.text = projectName ?? "Unnamed"
        }
    }
    
    var tasksCount: Int = 0 {
        didSet {
            tasksCountLabel.text = "tasks count: \(tasksCount)"
        }
    }
    
    func customizeWithProject(project: TMProject?) {
        projectName = project?.projectName
        tasksCount = project?.tasksCount.intValue ?? 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        customizeWithProject(project: nil)
        
        customSelectedFlag = false
    }
    
    // Custom flag for selected state
    // To avoid single selection handling
    // In cases when TMProjectsViewController is in projectsRemoveWorkflowState == .None
    // Also helps to avoid preselected cells
    var customSelectedFlag: Bool = false {
        didSet {
            if customSelectedFlag {
                selectionView.borderColor = UIColor.tmBlue()
                selectionView.borderWidth = 2
            } else {
                selectionView.borderColor = UIColor.clear
                selectionView.borderWidth = 0
            }
        }
    }
    
}
