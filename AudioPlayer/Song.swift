//
//  Song.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 19/5/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import UIKit

class Song: NSObject {
    var name: String!
    var album: String!
    var artwork: UIImage!
    var path: String!
    var fileURL : NSURL? {
        get {
            if let filePath = path {
                return NSURL(fileURLWithPath: filePath)
            }
            return nil
        }
    }
    
    init(name: String, album: String, artwork: UIImage, path: String) {
        self.name = name
        self.album = album
        self.artwork = artwork
        self.path = path
    }
}
