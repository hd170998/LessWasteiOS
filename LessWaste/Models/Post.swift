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
    var didSave = false
    var description: String!
    var link: String!
    
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
    func adjustSaved(save: Bool, completion: @escaping(Int) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.postId else { return }
        
        if save {
            // Actualiza tabla user-likes
            USER_SAVED_REF.child(currentUid).updateChildValues([postId: 1], withCompletionBlock: { (err, ref) in
                // Actualiza tabla post-likes
                self.didSave = true
            })
        }else{
            USER_SAVED_REF.child(currentUid).child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
                
            
                self.removeSave(withCompletion: { (likes) in
                    completion(likes)
                })
            })
        }
    }
    func removeSave(withCompletion completion: @escaping (Int) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_SAVED_REF.child(currentUid).child(self.postId).removeValue(completionBlock: { (err, ref) in
            self.didSave = false
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
    func deletePost() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Storage.storage().reference(forURL: self.imageUrl).delete(completion: nil)
        
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).child(self.postId).removeValue()
        }
        
        USER_FEED_REF.child(currentUid).child(postId).removeValue()
        
        USER_POSTS_REF.child(currentUid).child(postId).removeValue()
        
        POST_LIKES_REF.child(postId).observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            
            USER_LIKES_REF.child(uid).child(self.postId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let notificationId = snapshot.value as? String else { return }
                
                NOTIFICATIONS_REF.child(self.ownerUid).child(notificationId).removeValue(completionBlock: { (err, ref) in
                    
                    POST_LIKES_REF.child(self.postId).removeValue()
                    
                    USER_LIKES_REF.child(uid).child(self.postId).removeValue()
                })
            })
        }
        
        let words = description.components(separatedBy: .whitespacesAndNewlines)
        for var word in words {
            if word.hasPrefix("#") {
                
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                HASHTAG_POST_REF.child(word).child(postId).removeValue()
            }
        }
        
        COMMENT_REF.child(postId).removeValue()
        POSTS_REF.child(postId).removeValue()
    }
}
