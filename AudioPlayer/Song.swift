//
//  Song.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 19/5/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import Foundation
import CoreData

class Song: CDObject {
    static let ClassName = "Song"
    //var name: String!
    //var album: String!
    //var artwork: UIImage!
    //var path: String!
    var online: Bool!
    var fileURL : URL? {
        get {
            if let filePath = path {
                if filePath.contains("http"){
                    return URL(string: filePath)
                }else{
                    return URL(fileURLWithPath: filePath)
                }
            }
            return nil
        }
    }
    
    fileprivate var artworkURL: URL!
    
    
    /*
    init(name: String, album: String, artwork: UIImage, path: String) {
        super.init()
        self.name = name
        self.album = album
        self.artwork = UIImageJPEGRepresentation(artwork, 1.0)
        self.path = path
    }
 
 */
    func parseFromDictionary(withDictionary record : NSDictionary) {
        /*if let  username = record["username"] as? String {
         self.username = username
         }*/
        
        if let name = record["name"] as? String {
            self.name = name
        }
        
        if let path = record["coverimage_url"] as? String{
            self.path = path
        }
    }
}
