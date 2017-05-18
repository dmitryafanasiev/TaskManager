//
//  TMProject+CoreDataProperties.swift
//  TaskManager
//

import Foundation
import CoreData


extension TMProject {

    @NSManaged public var projectName: String?
    @NSManaged public var id: NSNumber
    @NSManaged public var tasksCount: NSNumber // Tpo fetch tasks count without retrieving the relationship.
    @NSManaged public var tasks: NSSet?
    @NSManaged public var creationDate: NSDate?
}

// MARK: Generated accessors for tasks
extension TMProject {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TMTask)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TMTask)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

extension TMProject {
    
    static func projectWithName(name: String?) -> TMProject? {
        guard let name = name else { return nil }
        return TMProject.fetchFromDefaultContext(withPredicate: NSPredicate(format: "projectName == %@", name))?.first
    }

    static func projectWithId(id: Int) -> TMProject? {
        return TMProject.fetchFromDefaultContext(withPredicate: NSPredicate(format: "id == %@", NSNumber(value: id)))?.first
    }
    
    static func projectWithNameOrNewOne(name: String) -> TMProject {
        let project: TMProject = TMProject.projectWithName(name: name) ?? AppDelegate.sharedDelegate.managedObjectContext.insertObject()
        if project.creationDate == nil {
            project.projectName = name
            project.creationDate = NSDate()
            let lastProjectId = UserDefaults.standard.integer(forKey: kLastProjectId)
            let newId = lastProjectId + 1
            project.id = NSNumber(value: newId)
            UserDefaults.standard.set(newId, forKey: kLastProjectId)
        }

        return project
    }
    
}
