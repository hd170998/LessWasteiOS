//
//  Comment.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 02/06/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import Foundation
import Firebase
class Comment {
    
    var uid: String!
    var commentText: String!
    var creationDate: Date!
    var user: User?
    
    init(user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.user = user
        
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        
        if let commentText = dictionary["commentText"] as? String {
            self.commentText = commentText
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
}
