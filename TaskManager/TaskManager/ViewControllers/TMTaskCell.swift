//
//  TMTaskCell.swift
//  TaskManager
//

import Foundation
import UIKit

protocol TMTaskCustomizationProtocol {
    func customizeWithTask(task: TMTask?)
}

class TMTaskCell: UICollectionViewCell, TMTaskCustomizationProtocol {
    @IBOutlet weak private var selectionView: UIView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var statusLabel: UILabel!
    @IBOutlet weak private var progresLabel: UILabel!
    @IBOutlet weak private var dueDateLabel: UILabel!
    
    func customizeWithTask(task: TMTask?) {
        nameLabel.text = task?.name ?? "Unnamed"
        statusLabel.text = "Status: " + (task?.currentState.rawValue ?? "")
        progresLabel.text = "Progress: " + String(task?.persentsOfCompletion ?? 0) + " %"
        if let date = task?.dueDate {
            dueDateLabel.text = "Due Date: " + date.tmDateFormat()
        } else {
           dueDateLabel.text = ""
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        customizeWithTask(task: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionView.roundView(radius: 10)
    }
    
}
