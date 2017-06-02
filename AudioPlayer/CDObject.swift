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
        let entity = NSEntityDescription.insertNewObject(forEntityName: String(describing: type(of: self)), into: context)
        
        super.init(entity: entity.entity, insertInto: entity.managedObjectContext)
        
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    func save() {
        let context = SaveManager.managedObjectContext
        do {
            try context.save()
        } catch {
        }
    }
    
}
