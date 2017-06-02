//
//  Artist+CoreDataProperties.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 16/6/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Artist {

    @NSManaged var name: String?
    @NSManaged var biography: String?
    @NSManaged var image: Data?
    @NSManaged var songlist: NSSet?

}
