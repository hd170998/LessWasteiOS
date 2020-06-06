//
//  Post.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 24/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    var user: User?
    var didLike = false
    var description: String!
    var link: String!
    var ingridients: String!
    
    init(postId: String!, user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.postId = postId
        
        self.user = user
        
        if let caption = dictionary["caption"] as? String {
            self.caption = caption
        }
        
        if let likes = dictionary["likes"] as? Int {
            self.likes = likes
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let ownerUid = dictionary["ownerUid"] as? String {
            self.ownerUid = ownerUid
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
        if let description = dictionary["descripcion"] as? String {
            self.description = description
        }
        
        if let ingridients = dictionary["ingridients"] as? String {
            self.ingridients = ingridients
        }
        
        if let link = dictionary["link"] as? String {
            self.link = link
        }
    }
    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.postId else { return }
        
        if addLike {
            // Actualiza tabla user-likes
            USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1], withCompletionBlock: { (err, ref) in
                //manda actualizaciones a
                self.sendLikeNotificationToServer()
                // Actualiza tabla post-likes
                POST_LIKES_REF.child(self.postId).updateChildValues([currentUid: 1], withCompletionBlock: { (err, ref) in
                    self.likes = self.likes + 1
                    self.didLike = true
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                    completion(self.likes)
                })
            })
        }else{
            USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
                //borra cualquier notificacion de la receta
                if let notificationID = snapshot.value as? String {
                    NOTIFICATIONS_REF.child(self.ownerUid).child(notificationID).removeValue(completionBlock: { (err, ref) in
                        self.removeLike(withCompletion: { (likes) in
                            completion(likes)
                        })
                    })
                }
                self.removeLike(withCompletion: { (likes) in
                    completion(likes)
                })
            })
        }
    }
    func removeLike(withCompletion completion: @escaping (Int) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(currentUid).child(self.postId).removeValue(completionBlock: { (err, ref) in
            
            POST_LIKES_REF.child(self.postId).child(currentUid).removeValue(completionBlock: { (err, ref) in
                guard self.likes > 0 else { return }
                self.likes = self.likes - 1
                self.didLike = false
                POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                completion(self.likes)
            })
        })
    }
    func sendLikeNotificationToServer() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        if currentUid != self.ownerUid {
            let values = ["checked": 0,
                          "creationDate": creationDate,
                          "uid": currentUid,
                          "type": LIKE_INT_VALUE,
                          "postId": postId!] as [String : Any]
            
            let notificationRef = NOTIFICATIONS_REF.child(self.ownerUid).childByAutoId()
            notificationRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                USER_LIKES_REF.child(currentUid).child(self.postId).setValue(notificationRef.key)
            })
        }
    }
}