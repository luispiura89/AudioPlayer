//
//  Query.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 16/6/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import UIKit
import CoreData

class Query: NSObject {
    
    var className : String
    fileprivate var request = NSFetchRequest<NSFetchRequestResult>()
    
    init(className : String) {
        self.className = className
    }
    
    func limit(_ n : Int) {
        request.fetchLimit = n
    }
    
    func ascending(_ key : String) {
        request.sortDescriptors = [NSSortDescriptor(key : key, ascending: true )]
    }
    
    func descending(_ key : String) {
        request.sortDescriptors = [NSSortDescriptor(key : key, ascending: false )]
    }
    
    func equalTo(_ key : String, value : AnyObject) {
        setTypeToPredicate(key, value: value, qoperator: "=")
    }
    
    func contains(_ key : String, substring : String) {
        setTypeToPredicate(key, value: substring as AnyObject, qoperator: "CONTAINS[cd]")
    }
    
    func greaterThan(_ key : String, value : AnyObject) {
        setTypeToPredicate(key, value: value, qoperator: ">")
    }
    
    func lessThan(_ key : String, value : AnyObject) {
        setTypeToPredicate(key, value: value, qoperator: "<")
    }
    
    fileprivate func setTypeToPredicate (_ key : String, value : AnyObject, qoperator : String ) {
        var afterPredicate = ""
        if request.predicate != nil {
            afterPredicate = "\(request.predicate!.predicateFormat) AND"
        }
        if let value = value as? String {
            request.predicate = NSPredicate(format: "\(afterPredicate) \(key) \(qoperator) %@", value)
        } else if let value = value as? NSNumber {
            request.predicate = NSPredicate(format: "\(afterPredicate) \(key) \(qoperator) %@", value)
        } else if let value = value as? Date {
            request.predicate = NSPredicate(format: "\(afterPredicate) \(key) \(qoperator) %@", value as CVarArg)
        }
    }
    
    func find() -> [AnyObject] {
        return SaveManager.getDataForClass(className, request: request)
    }
    

}
