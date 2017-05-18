//
//  TMTaskDetailsViewModel.swift
//  TaskManager
//

import Foundation

enum TMTaskDetailsScreenMode {
    case CreateNew
    case ViewAndEdit
}

class TMTaskDetailsViewModel: ControllerViewModel {
    static let showFromTasksScreenSegueId = "showFromTasksScreenSegueId"
    
    var mode: TMTaskDetailsScreenMode = .CreateNew
    var taskId: NSNumber? {
        didSet {
            if let id = taskId {
                task = TMTask.taskWithId(id: id.intValue)
                mode = .ViewAndEdit
            } else {
                task = nil
            }
        }
    }
    var projectId: NSNumber?
    private(set) var task: TMTask?
    
    func saveTask(withName name: String, status: TMTaskState, progress: Int, dueDate: Date) -> Bool {
        if let projectId = projectId, let project = TMProject.projectWithId(id: projectId.intValue) {
            if task == nil {
                task = TMTask.newTask()
            }
            task?.name = name
            task?.currentState = status
            task?.persentsOfCompletion = progress
            task?.dueDate = dueDate
            
            AppDelegate.sharedDelegate.saveContext()
            
            if mode == .CreateNew {
                project.addToTasks(task!)
                let tasksCount = project.tasksCount.intValue
                project.tasksCount = NSNumber(value: tasksCount + 1)
                AppDelegate.sharedDelegate.saveContext()
            }
            
            return true
        }
        
        return false
    }
    
    func deleteTask() -> Bool {
        if let task = task {
            AppDelegate.sharedDelegate.managedObjectContext.delete(task)
            self.task = nil
            if let projectId = projectId {
                if let project = TMProject.projectWithId(id: projectId.intValue) {
                    let tasksCount = project.tasksCount
                    if tasksCount.intValue > 0 {
                        project.tasksCount = NSNumber(value: tasksCount.intValue - 1)
                    }
                }
            }
            AppDelegate.sharedDelegate.saveContext()
            return true
        }
        
        return false
    }
    
}
