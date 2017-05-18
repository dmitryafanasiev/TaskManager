//
//  TMTasksSortingView.swift
//  TaskManager
//

import Foundation
import UIKit

class TMTasksSortingView: UIView {
    @IBOutlet weak private var currentSortingButton: UIButton!
    
    var sortingButtonPressed: (()->())?
    
    var selectedSorting: TasksSorting = .NewestFirst {
        didSet {
            currentSortingButton.setTitle(selectedSorting.rawValue, for: .normal)
        }
    }
    
    @IBAction func didPressSortingButton() {
        sortingButtonPressed?()
    }
    
}
