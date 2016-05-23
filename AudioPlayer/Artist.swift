//
//  Artist.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 19/5/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import UIKit

class Artist: NSObject {
    var name: String!
    var biography: String!
    var image: UIImage!
    var songList: [Song]!
    
    init(name: String, biography: String, image: UIImage) {
        self.name = name
        self.biography = biography
        self.image = image
        songList = [Song]()
    }
}
