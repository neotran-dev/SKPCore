//
//  NSManagedObject++.swift
//  SKPCore
//
//  Created by Lam Tran on 16/05/2021.
//

import Foundation
import CoreData

public extension NSManagedObject {
    
    static func createEntity<T: NSManagedObject>(in context: NSManagedObjectContext) -> T? {
        let entityName = String(describing: T.self)
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? T
    }
    
    static func find<T: NSManagedObject>(by attributes: [String: Any] = [:], context: NSManagedObjectContext) -> [T] {
        let entityName = String(describing: T.self)
        let req = NSFetchRequest<T>(entityName: entityName)
        
        if attributes.count > 0 {
            var predicates = [NSPredicate]()
            attributes.forEach { (key: String, value: Any) in
                if let val = value as? Date {
                    predicates.append(NSPredicate(format: "%K == %@", key, val as NSDate))
                } else {
                    predicates.append(NSPredicate(format: "%K == %@", key, value as! CVarArg))
                }
            }
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        do {
            let results = try context.fetch(req)
            return results
        } catch {
            print("Find by predicates error: \(error.localizedDescription)")
            return []
        }
    }
    
    static func first<T: NSManagedObject> (by attributes: [String: Any] = [:], context: NSManagedObjectContext) -> T? {
        return find(by: attributes, context: context).first
    }
    
    static func count(by attributes: [String: Any] = [:], context: NSManagedObjectContext) -> Int {
        let entityName = String(describing: type(of: self))
        
        let req = NSFetchRequest<Self>(entityName: entityName)
        
        if attributes.count > 0 {
            var predicates = [NSPredicate]()
            attributes.forEach { (key: String, value: Any) in
                predicates.append(NSPredicate(format: "%K = %@", key, value as! CVarArg))
            }
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        do {
            let results = try context.count(for: req)
            return results
        } catch {
            print("Find by predicates error: \(error.localizedDescription)")
            return 0
        }
    }
    
    func delete(in context: NSManagedObjectContext) {
        context.delete(self)
    }
    
}
