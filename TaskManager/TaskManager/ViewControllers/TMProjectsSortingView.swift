//
//  PostsSortingView.swift
//  TaskManager
//
//

import Foundation
import UIKit

class TMProjectsSortingView: UIView {
    @IBOutlet weak private var smallProjectImageView: UIImageView!
    @IBOutlet weak private var largeProjectImageView: UIImageView!
    @IBOutlet weak private var currentSortingButton: UIButton!
    
    var sortingButtonPressed: (()->())?
    var representationButtonPressed: ((ProjectsRepresentation)->())?
    
    var selectedSorting: ProjectsSorting = .NewestFirst {
        didSet {
            currentSortingButton.setTitle(selectedSorting.rawValue, for: .normal)
        }
    }
    
    var selectedRepresentation: ProjectsRepresentation = .Large {
        didSet {
            switch selectedRepresentation {
            case .Large:
                largeProjectImageView.tintColor = UIColor.tmPrimaryDarkGrey()
                smallProjectImageView.tintColor = UIColor.tmSecondaryMediumGrey()
                break
            case .Small:
                largeProjectImageView.tintColor = UIColor.tmSecondaryMediumGrey()
                smallProjectImageView.tintColor = UIColor.tmPrimaryDarkGrey()
                break
            }
            
            if selectedRepresentation != oldValue {
                representationButtonPressed?(selectedRepresentation)
            }
        }
    }
    
    @IBAction func didPressSortingButton() {
        sortingButtonPressed?()
    }
    
    @IBAction func didPressLargeRepresentationButton() {
        selectedRepresentation = .Large
    }
    
    @IBAction func didPressSmallRepresentationButton() {
        selectedRepresentation = .Small
    }
    
}
