//
//  Artist.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 19/5/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Artist: CDObject {
    
    static let ClassName = "Artist"
    private var imageURL: NSURL!
    var id: String!
    //var name: String!
    //var biography: String!
    //var image: UIImage!
    //var songList: [Song]!
    
    /*
    init(name: String, biography: String, image: UIImage) {
        super.init()
        self.name = name
        self.biography = biography
        self.image = UIImageJPEGRepresentation(image, 1.0)
    }
 */
    
    func parseFromDictionary(withDictionary record : NSDictionary) {
        /*if let  username = record["username"] as? String {
         self.username = username
         }*/
        
        if let name = record["name"] as? String {
            self.name = name
        }
        
        if let id = record["id"] as? String {
            self.id = id
        }
        
        if let displayName = record["bio"] as? String {
            self.biography = displayName
        }
        
        
        if let imageURL = record["coverimage_url"] as? String{
            self.imageURL = NSURL(string: imageURL)
        }
    }
    
    func downloadImageIfNeeded(completionBlock : (image : UIImage) -> Void) {
        if self.image != nil {
            if let image = UIImage(data: self.image!) {
                completionBlock(image: image)
            }
            return
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let imageURL = self.imageURL {
                if let data = NSData(contentsOfURL: self.imageURL) {
                    if let image = UIImage(data: data) {
                        self.image = data
                        dispatch_async(dispatch_get_main_queue(), {
                            completionBlock(image: image)
                        })
                        
                    }
                }
            }
        }
    }
}
