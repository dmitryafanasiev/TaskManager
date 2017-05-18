//
//  ControllerViewModel.swift
//  TaskManager
//

import Foundation
import CoreGraphics

protocol CellSizeProtocol {
    func cellSize(collectionViewSize: CGSize) -> CGSize
}

class ControllerViewModel : ViewModel, CellSizeProtocol {
    
    func cellSize(collectionViewSize: CGSize) -> CGSize {
        // Override to implement
        return CGSize.zero
    }
    
}
