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
    private var request = NSFetchRequest()
    
    init(className : String) {
        self.className = className
    }
    
    func limit(n : Int) {
        request.fetchLimit = n
    }
    
    func ascending(key : String) {
        request.sortDescriptors = [NSSortDescriptor(key : key, ascending: true )]
    }
    
    func descending(key : String) {
        request.sortDescriptors = [NSSortDescriptor(key : key, ascending: false )]
    }
    
    func equalTo(key : String, value : AnyObject) {
        setTypeToPredicate(key, value: value, qoperator: "=")
    }
    
    func contains(key : String, substring : String) {
        setTypeToPredicate(key, value: substring, qoperator: "CONTAINS[cd]")
    }
    
    func greaterThan(key : String, value : AnyObject) {
        setTypeToPredicate(key, value: value, qoperator: ">")
    }
    
    func lessThan(key : String, value : AnyObject) {
        setTypeToPredicate(key, value: value, qoperator: "<")
    }
    
    private func setTypeToPredicate (key : String, value : AnyObject, qoperator : String ) {
        var afterPredicate = ""
        if request.predicate != nil {
            afterPredicate = "\(request.predicate!.predicateFormat) AND"
        }
        if let value = value as? String {
            request.predicate = NSPredicate(format: "\(afterPredicate) \(key) \(qoperator) %@", value)
        } else if let value = value as? NSNumber {
            request.predicate = NSPredicate(format: "\(afterPredicate) \(key) \(qoperator) %@", value)
        } else if let value = value as? NSDate {
            request.predicate = NSPredicate(format: "\(afterPredicate) \(key) \(qoperator) %@", value)
        }
    }
    
    func find() -> [AnyObject] {
        return SaveManager.getDataForClass(className, request: request)
    }
    

}
