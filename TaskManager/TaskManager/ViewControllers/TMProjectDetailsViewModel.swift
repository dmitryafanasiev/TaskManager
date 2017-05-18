//
//  TMProjectDetailsViewModel.swift
//  TaskManager
//

import Foundation
import CoreData
import CoreGraphics

enum TasksSorting: String {
    case OldestFirst = "Oldest First"
    case NewestFirst = "Newest First"
    case DueDateAscending = "Due Date Ascending"
    case DueDateDescending = "Due Date Descending"
    case MostCompleted = "Most Completed"
    case LessCompleted = "Less Completed"
    
    static let allValues = [OldestFirst, NewestFirst, DueDateAscending, DueDateDescending, MostCompleted, LessCompleted]
}


class TMProjectDetailsViewModel: ControllerViewModel {
    static let showFromProjectsScreenSegueId = "showFromProjectsScreenSegueId"
    var projectId: NSNumber? {
        didSet {
            if let id = projectId {
                project = TMProject.projectWithId(id: id.intValue)
            } else {
                project = nil
            }
        }
    }
    private(set) var project: TMProject?
    
    let cellSpacing: CGFloat = 10
    
    var selectedSortingChangeCallbak: ((TasksSorting)->())?
    var selectedSorting: TasksSorting = .NewestFirst {
        didSet {
            if selectedSorting != oldValue {
                selectedSortingChangeCallbak?(selectedSorting)
            }
        }
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
        case .DueDateAscending:
            sortDescriptors.append(NSSortDescriptor(key: "dueDate", ascending: true))
            break
        case .DueDateDescending:
            sortDescriptors.append(NSSortDescriptor(key: "dueDate", ascending: false))
            break
        case .MostCompleted:
            sortDescriptors.append(NSSortDescriptor(key: "completion", ascending: false))
            break
        case .LessCompleted:
            sortDescriptors.append(NSSortDescriptor(key: "completion", ascending: true))
            break
        }
        
        return sortDescriptors
    }
    
    func predicate() -> NSPredicate? {
        if let project = project {
            return NSPredicate(format: "project == %@", project.objectID)
        }
        
        return nil
    }
    
    override func cellSize(collectionViewSize: CGSize) -> CGSize {
        if collectionViewSize.width > collectionViewSize.height {
            return CGSize(width: (collectionViewSize.width - cellSpacing) * 0.5, height: 150)
        } else {
            return CGSize(width: (collectionViewSize.width - cellSpacing), height: 150)
        }
    }
    
}
