//
//  TMProjectsViewModel.swift
//  TaskManager
//

import Foundation
import CoreData
import CoreGraphics

enum ProjectsRepresentation {
    case Large
    case Small
}

enum ProjectsSorting: String {
    case OldestFirst = "Oldest First"
    case NewestFirst = "Newest First"
    case AlphabeticAscending = "Alphabetic Ascending"
    case AlphabeticDescending = "Alphabetic Descending"
    
    static let allValues = [OldestFirst, NewestFirst, AlphabeticAscending, AlphabeticDescending]
}

enum ProjectsRemoveWorkflowState {
    case None
    case SelectingToRemove
}

class TMProjectsViewModel: ControllerViewModel {
    let lineSpacing: CGFloat = 10
    let cellSpacing: CGFloat = 10
    
    var projectsIdsToRemove = Set<NSNumber>()
    
    var representationChangeCallback: (()->())?
    var projectCreationCallback: ((Bool, String?)->())?
    var selectedRepresentation: ProjectsRepresentation = .Large {
        didSet {
            if selectedRepresentation != oldValue {
                representationChangeCallback?()
            }
        }
    }
    
    var selectedSortingChangeCallbak: ((ProjectsSorting)->())?
    var selectedSorting: ProjectsSorting = .NewestFirst {
        didSet {
            if selectedSorting != oldValue {
                selectedSortingChangeCallbak?(selectedSorting)
            }
        }
    }
    
    var projectsRemoveWorkflowState: ProjectsRemoveWorkflowState = .None
    
    func createNewProjectWithName(name: String) {
        if let _ = TMProject.projectWithName(name: name) {
            projectCreationCallback?(false, "Project with such name already exists")
        } else {
            let _ = TMProject.projectWithNameOrNewOne(name: name)
            projectCreationCallback?(true, nil)
            AppDelegate.sharedDelegate.saveContext()
        }
    }
    
    func removeSelectedProjects() {
        if projectsIdsToRemove.count == 0 {
            return
        }
        let predicate = NSPredicate(format: "id IN %@", projectsIdsToRemove)
        if let results = TMProject.fetchFromDefaultContext(withPredicate: predicate) {
            AppDelegate.sharedDelegate.managedObjectContext.removeObjects(objects: results)
            AppDelegate.sharedDelegate.saveContext()
        }
        
        projectsIdsToRemove.removeAll()
    }
    
    func sortDescriptor() -> [NSSortDescriptor] {
        var sortDescriptors = [NSSortDescriptor]()
        switch selectedSorting {
        case .NewestFirst:
            sortDescriptors.append(NSSortDescriptor(key: "creationDate", ascending: false))
            break
        case .OldestFirst:
            sortDescriptors.append(NSSortDescriptor(key: "creationDate", ascending: true))
            break
        case .AlphabeticAscending:
            sortDescriptors.append(NSSortDescriptor(key: "projectName", ascending: true))
            break
        case .AlphabeticDescending:
            sortDescriptors.append(NSSortDescriptor(key: "projectName", ascending: true))
            break
        }
        
        return sortDescriptors
    }
    
    func projectSelectionStateChanged(projectId: NSNumber, isSelected selected: Bool) {
        if selected {
            projectsIdsToRemove.insert(projectId)
        } else {
            projectsIdsToRemove.remove(projectId)
        }
    }
    
    override func cellSize(collectionViewSize: CGSize) -> CGSize {
        switch selectedRepresentation {
        case .Large:
            // check for device orientation, should work as expected for this ViewController
            if collectionViewSize.width > collectionViewSize.height {
                return CGSize(width: (collectionViewSize.width - cellSpacing) * 0.5, height: 100)
            } else {
                return CGSize(width: (collectionViewSize.width - cellSpacing), height: 100)
            }
        case .Small:
            if collectionViewSize.width > collectionViewSize.height {
                return CGSize(width: (collectionViewSize.width - 3 * cellSpacing) * 0.25, height: 100)
            } else {
                return CGSize(width: (collectionViewSize.width - cellSpacing) * 0.5, height: 100)
            }
        }
    }
    
}
