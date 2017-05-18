//
//  TMTask+CoreDataProperties.swift
//  TaskManager
//

import Foundation
import CoreData

enum TMTaskState: String {
    case New = "New"
    case InProgress = "In Progress"
    case Done = "Done"
    
    static let allValues = [New, InProgress, Done]
}

extension TMTask {

    @NSManaged public var name: String?
    @NSManaged public var completion: NSNumber
    @NSManaged public var state: String
    @NSManaged public var estimatedTime: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var creationDate: Date?
    @NSManaged public var dueDate: Date?
    @NSManaged public var id: NSNumber
    @NSManaged public var project: TMProject?

}

extension TMTask {
    
    var currentState: TMTaskState {
        get {
            return TMTaskState(rawValue: state) ?? TMTaskState.New
        }
        set(newState) {
            state = newState.rawValue
            switch newState {
            case .New:
                completion = NSNumber(value: 0)
                startDate = nil
            case .Done:
                completion = NSNumber(value: 100)
                if startDate == nil {
                    startDate = Date()
                }
            case .InProgress:
                startDate = Date()
            }
        }
    }
    
    var persentsOfCompletion: Int {
        get {
            return completion.intValue
        }
        set(newPercents) {
            if newPercents >= 0 && newPercents <= 100 {
                completion = NSNumber(value: newPercents)
                if newPercents == 100 {
                    state = TMTaskState.Done.rawValue
                } else {
                    state = TMTaskState.InProgress.rawValue
                }
            }
        }
    }
    
    static func taskWithId(id: Int) -> TMTask? {
        return TMTask.fetchFromDefaultContext(withPredicate: NSPredicate(format: "id == %@", NSNumber(value: id)))?.first
    }
    
    static func taskWithIdOrNewOne(id: Int) -> TMTask {
        let task: TMTask = taskWithId(id: id) ?? newTask()
        
        return task
    }
    
    static func newTask() -> TMTask {
        let task: TMTask = AppDelegate.sharedDelegate.managedObjectContext.insertObject()
        task.creationDate = Date()
        let lastTaskId = UserDefaults.standard.integer(forKey: kLastTaskId)
        let newId = lastTaskId + 1
        task.id = NSNumber(value: newId)
        UserDefaults.standard.set(newId, forKey: kLastTaskId)
        
        return task
    }
    
}
