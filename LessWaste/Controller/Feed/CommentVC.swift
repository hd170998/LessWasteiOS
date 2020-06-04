//
//  CommentVC.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 02/06/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "CommentCell"

class CommentVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var comments = [Comment]()
    var post: Post?
    // MARK: Properties
    
    lazy var containerView : CommentInputAccesoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let containerView = CommentInputAccesoryView(frame: frame)
        
        containerView.delegate = self
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        navigationItem.title = "Comentarios"
        self.collectionView!.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        fetchComments()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    // MARK: UICollectionViewFormat
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }

    // MARK: UICollectionViewDataSource
    


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return comments.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
    
        // Configure the cell
        cell.comment = comments[indexPath.item]
        return cell
    }
    // MARK: - API
    
    func fetchComments() {
        guard let postId = self.post?.postId else { return }

        COMMENT_REF.child(postId).observe(.childAdded) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUser(with: uid, completion: { (user) in
                let comment = Comment(user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView?.reloadData()
            })
        }
    }
    
    func uploadCommentNotificationToServer() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.post?.postId else { return }
        guard let uid = post?.user?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // Valores
        let values = ["checked": 0,
                      "creationDate": creationDate,
                      "uid": currentUid,
                      "type": COMMENT_INT_VALUE,
                      "postId": postId] as [String : Any]
        
        // Sube comentario para la notificacion
        
        if uid != currentUid {
            NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(values)
        }
    }

}
extension CommentVC: CommentInputAccesoryViewDelegate {
    
    func didSubmit(forComment comment: String) {
        
        guard let postId = self.post?.postId else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = ["commentText": comment,
                      "creationDate": creationDate,
                      "uid": uid] as [String : Any]
        
        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            self.uploadCommentNotificationToServer()
            self.containerView.clearCommentTextView()
        }
    }
}
