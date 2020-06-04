//
//  NotificationsVC.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 15/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NotificationCell"
class NotificationsVC: UITableViewController, NotificationCellDelegate {
    
    var timer: Timer?
    var notifications = [Notification]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = .clear
        navigationItem.title = "Notificaciones"
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        fetchNotifications()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        let notification = notifications[indexPath.row]
        
        cell.notification = notification
        
        if notification.notificationType == .Comment {
            if let commentText = notification.commentText {
                cell.configureNotificationLabel(withCommentText: commentText)
            }
        }
        
        cell.delegate = self
        return cell
    }
    
    // MARK: - Delegate
    func handleFollowTapped(for cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            
            // handle unfollow user
            user.unfollow()
            cell.followButton.configure(didFollow: false)
        } else {
            
            // handle follow user
            user.follow()
            cell.followButton.configure(didFollow: true)
        }
    }
    
    @objc func handleSortNotifications() {
        self.notifications.sort { (notification1, notification2) -> Bool in
            return notification1.creationDate > notification2.creationDate
        }
        self.tableView.reloadData()
    }
    
    func handleReloadTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotifications), userInfo: nil, repeats: false)
    }
    
    func handlePostTapped(for cell: NotificationCell) {
        guard let post = cell.notification?.post else { return }
        guard let notification = cell.notification else { return }
        
        if notification.notificationType == .Comment {
            let commentController = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
            commentController.post = post
            navigationController?.pushViewController(commentController, animated: true)
        } else {
            let feedController = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
            feedController.viewSinglePost = true
            feedController.post = post
            navigationController?.pushViewController(feedController, animated: true)
        }
    }
    func getCommentData(forNotification notification: Notification) {
        
        guard let postId = notification.postId else { return }
        guard let commentId = notification.commentId else { return }
        
        COMMENT_REF.child(postId).child(commentId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let commentText = dictionary["commentText"] as? String else { return }
            
            notification.commentText = commentText
        }
    }
    
    
    func fetchNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.forEach({ (snapshot) in
                let notificationId = snapshot.key
                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                Database.fetchUser(with: uid, completion: { (user) in
                    
                    // Caso para la notificaciones de publicaciones
                    if let postId = dictionary["postId"] as? String {
                        Database.fetchPost(with: postId, completion: { (post) in
                            let notification = Notification(user: user, post: post, dictionary: dictionary)
                            if notification.notificationType == .Comment {
                                self.getCommentData(forNotification: notification)
                            }
                            self.notifications.append(notification)
                            self.handleReloadTable()
                        })
                    } else {
                        let notification = Notification(user: user, dictionary: dictionary)
                        self.notifications.append(notification)
                        self.handleReloadTable()
                    }
                })
                NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
            })
        }
    }


}
