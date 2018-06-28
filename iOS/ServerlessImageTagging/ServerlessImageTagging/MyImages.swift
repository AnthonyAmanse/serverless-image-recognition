//
//  MyImages.swift
//  ServerlessImageTagging
//
//  Created by Anthony on 6/27/18.
//  Copyright © 2018 Joe Anthony Peter Amanse. All rights reserved.
//

import Foundation

struct ImageUploaded: Codable {
    var id: String?
    var image: Data?
    var tags: [Tag]?
    
    init?(id: String?, image: Data?, tags: [Tag]?) {
        self.id = id
        self.image = image
        self.tags = tags
    }
}

struct Tag: Codable {
    var tag: String
    var score: Float
    
    enum CodingKeys: String, CodingKey {
        case tag = "class"
        case score
    }
    
    init?(tag: String, score: Float) {
        self.tag = tag
        self.score = score
    }
}
