//
//  CoreDataCollectionViewController.swift
//  TaskManager
//

import CoreData
import UIKit

protocol HidingNavigationBarProtocol {
    var yOffsetToAnimateNavigationBar: CGFloat { get set }
    var dOffset: CGFloat { get set }
    var lastOffset: CGFloat { get set }
    var shouldHideNavigationBarOnScroll: Bool { get set }
    var navBarIsHidden: Bool { get set }
    
    func hideNavigationBar()
    func showNavigationBar()
    func insetsForState(state: Bool) -> UIEdgeInsets
}

class CoreDataCollectionViewController: CollectonViewWithKeyboardViewController, HidingNavigationBarProtocol {
    class UpdateItem {
        var startIndex: IndexPath?
        var endIndex: IndexPath?
        var sectionInfo: NSFetchedResultsSectionInfo?
        var sectionIndex: Int?
        var type: NSFetchedResultsChangeType?
    }
    
    private var updateItems: [UpdateItem]?
    private var needReloadInsteadOfBatchUpdates = false
    
    var minimumElementsOnPageToShowNavigationBar = 3
    var yOffsetToAnimateNavigationBar: CGFloat = 150
    var dOffset: CGFloat = 0
    var lastOffset: CGFloat = 0
    var navBarIsHidden: Bool = false
    var shouldHideNavigationBarOnScroll = false {
        didSet {
            if !shouldHideNavigationBarOnScroll {
                showNavigationBar()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        if let _ = navigationController {
            collectionView.contentInset = insetsForState(state: false)
            collectionView.scrollIndicatorInsets = insetsForState(state: false)
            lastOffset = collectionView.contentOffset.y
        }
        
        fetchResultControllerWillChangeContent = { [weak self] in
            self?.updateItems = [UpdateItem]()
        }
        
        fetchResultControllerDidChangeContent = { [weak self] in
            guard let strongSelf = self, let updateItems = self?.updateItems else {
                return
            }
            if strongSelf.needReloadInsteadOfBatchUpdates {
                strongSelf.needReloadInsteadOfBatchUpdates = false
                strongSelf.updateItems = nil
                strongSelf.collectionView.reloadData()
                strongSelf.checkNavigationBarAvailability()
            } else {
                strongSelf.collectionView?.performBatchUpdates({
                    for item in updateItems {
                        switch item.type! {
                        case .insert:
                            if item.sectionInfo == nil {
                                if let index = item.endIndex {
                                    strongSelf.collectionView.insertItems(at: [index])
                                }
                            } else {
                                strongSelf.collectionView.insertSections(IndexSet(integer: item.sectionIndex!))
                            }
                            break
                        case .delete:
                            if item.sectionInfo == nil {
                                if let index = item.startIndex {
                                    strongSelf.collectionView.deleteItems(at: [index])
                                }
                            } else {
                                strongSelf.collectionView.deleteSections(IndexSet(integer: item.sectionIndex!))
                            }
                            break
                        case .move:
                            if item.sectionInfo == nil {
                                if let index = item.startIndex {
                                    strongSelf.collectionView.insertItems(at: [index])
                                }
                                if let endIndex = item.endIndex {
                                    strongSelf.collectionView.deleteItems(at: [endIndex])
                                }
                            }
                        case .update:
                            if item.sectionInfo == nil {
                                if let index = item.startIndex {
                                    strongSelf.collectionView.reloadItems(at: [index])
                                }
                            } else {
                                strongSelf.collectionView.reloadSections(IndexSet(integer: item.sectionIndex!))
                            }
                            break
                        }
                    }
                }, completion: { completed in
                        if completed {
                            strongSelf.updateItems = nil
                            
                            strongSelf.checkNavigationBarAvailability()
                        }
                })
            }
        }
        
        fetchResultControllerDidChangeObject = { [weak self] (object, indexPath, type, newIndexPath) in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.needReloadInsteadOfBatchUpdates {
                return
            }
            
            var needToAppendBatchUpdate = false
            
            switch type {
            case .insert, .move:
                strongSelf.needReloadInsteadOfBatchUpdates = true
            case .delete:
                if let indexPath = indexPath {
                    let sectionsNumber = strongSelf.collectionView.numberOfItems(inSection: indexPath.section)
                    if sectionsNumber <= 1 {
                        strongSelf.needReloadInsteadOfBatchUpdates = true
                    } else {
                        needToAppendBatchUpdate = true
                    }
                } else {
                    strongSelf.needReloadInsteadOfBatchUpdates = true
                }
            case .update:
                needToAppendBatchUpdate = true
            }
            
            if needToAppendBatchUpdate {
                if type == .move {
                    let item1 = UpdateItem()
                    item1.type = .delete
                    item1.startIndex = indexPath
                    item1.endIndex = indexPath
                    strongSelf.updateItems?.append(item1)
                    
                    let item2 = UpdateItem()
                    item2.type = .insert
                    item2.startIndex = newIndexPath
                    item2.endIndex = newIndexPath
                    strongSelf.updateItems?.append(item2)
                } else {
                    let item = UpdateItem()
                    item.type = type
                    item.startIndex = indexPath
                    item.endIndex = newIndexPath
                    strongSelf.updateItems?.append(item)
                }
            }
        }
        
        fetchResultControllerDidChangeSection = { [weak self] (section, index, type) in
            guard let strongSelf = self else {
                return
            }
            if type != .update {
                strongSelf.needReloadInsteadOfBatchUpdates = true
            } else {
                let item = UpdateItem()
                item.type = type
                item.sectionInfo = section
                item.sectionIndex = index
                strongSelf.updateItems?.append(item)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchLocalData()
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        showNavigationBar()
    }
    
    func showNavigationBar() {
        if let navController = navigationController {
            navController.setNavigationBarHidden(false, animated: true)
            collectionView.contentInset = insetsForState(state: false)
            collectionView.scrollIndicatorInsets = insetsForState(state: false)
            navBarIsHidden = false
            dOffset = 0
        }
    }
    
    func hideNavigationBar() {
        if let navController = navigationController {
            navController.setNavigationBarHidden(true, animated: true)
            collectionView.contentInset = insetsForState(state: true)
            collectionView.scrollIndicatorInsets = insetsForState(state: true)
            navBarIsHidden = true
            dOffset = 0
        }
    }
    
    func insetsForState(state: Bool) -> UIEdgeInsets {
        guard let _ = navigationController else {
            return UIEdgeInsets.zero
        }
        
        if state {
            return suggestedInsets
        } else {
            return suggestedInsets
        }
    }
    
    private func checkNavigationBarAvailability() {
        if let objects = fetchResultController?.fetchedObjects {
            if objects.count <= minimumElementsOnPageToShowNavigationBar {
                showNavigationBar()
            }
        }
    }
    
}

extension CoreDataCollectionViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if shouldHideNavigationBarOnScroll {
            dOffset += collectionView.contentOffset.y - lastOffset
            lastOffset = collectionView.contentOffset.y
            
            if collectionView.contentOffset.y < 0 {
                showNavigationBar()
            } else {
                if dOffset > yOffsetToAnimateNavigationBar {
                    hideNavigationBar()
                } else if dOffset < -yOffsetToAnimateNavigationBar {
                    showNavigationBar()
                }
            }
        }
    }
}
