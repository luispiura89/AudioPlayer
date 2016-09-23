//
//  CDObject.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 16/6/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import Foundation
import CoreData

class CDObject: NSManagedObject {
    init() {
        let context = DataManager.managedObjectContext
        let entity = NSEntityDescription.insertNewObjectForEntityForName(String(self.dynamicType), inManagedObjectContext: context)
        
        super.init(entity: entity.entity, insertIntoManagedObjectContext: entity.managedObjectContext)
        
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    func save() {
        let context = SaveManager.managedObjectContext
        do {
            try context.save()
        } catch {
        }
    }
    
}
