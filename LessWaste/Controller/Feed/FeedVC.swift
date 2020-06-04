//
//  FeedVC.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 15/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import  Firebase

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {
        
    var posts = [Post]()
    var viewSinglePost = false
    var post: Post?
    var currentKey: String?
    var userProfileController: UserProfileVC?

    override func viewDidLoad() {
        self.collectionView?.backgroundColor = .white
        super.viewDidLoad()
        
        //actualizar
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        // Register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        configureNavigationBar()
        fetchPosts()

        // Do any additional setup after loading the view.
    }
    // MARK: UICollectionFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        var height = width + 8 + 8 + 40
        height += 50
        height += 60
        return CGSize(width: width, height: height)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewSinglePost{
            return 1
        }
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.delegate = self
        if viewSinglePost{
           if let post = self.post {
                cell.post = post
            }
        }else{
            cell.post = posts[indexPath.item]
        }
        
        return cell
    }
    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do {
                try Auth.auth().signOut()
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                
                
                navController.modalPresentationStyle = .fullScreen
                
                self.present(navController, animated: true, completion: nil)
            } catch {
                
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 4 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }
    
    // MARK: Delegate
    func handleUsernameTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = post.user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func handleOptionsTapped(for cell: FeedCell) {
        print("options")
    }
    
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool) {
        guard let post = cell.post else { return }
        
        if post.didLike {
            // quitar el like
            if !isDoubleTap {
                post.adjustLikes(addLike: false, completion: { (likes) in
                    cell.likesLabel.text = "\(likes) Me gusta"
                    cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    cell.likeButton.tintColor = .red

                })
            }
        } else {
            // poner el like
            post.adjustLikes(addLike: true, completion: { (likes) in
                cell.likesLabel.text = "\(likes) Me gusta"
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                cell.likeButton.tintColor = .red
            })
        }
    }
    
    func handleCommentTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.post = post
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func handleConfigureLikeButton(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            // Revisa si el usuario en sesion ya dio Me gusta
            if snapshot.hasChild(postId) {
                post.didLike = true
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            } else {
                post.didLike = false
                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        }
    }
    
    func handleShowLikes(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        
        let followLikeVC = FollowLikeVC()
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 2)
        followLikeVC.postId = postId
        navigationController?.pushViewController(followLikeVC, animated: true)
    }
    
    func configureCommentIndicatorView(for cell: FeedCell) {
        print("commentIndicator")
    }
    func handleDetailTapped(for cell: FeedCell){
        let detailPostVC = DetailPost()
        detailPostVC.post = cell.post
        navigationController?.pushViewController(detailPostVC, animated: true)
    }
    
    @objc func handleItems(){
        
    }
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView?.reloadData()
    }
    
    func configureNavigationBar() {
        if !viewSinglePost{
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil.and.outline"), style: .plain, target: self, action: #selector(handleItems))
        
        self.navigationItem.title = "Home"
        
    }
    func fetchPosts() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if currentKey == nil {
            USER_FEED_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
                self.collectionView?.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    self.fetchPost(withPostId: postId)
                })
                self.currentKey = first.key
            })
        } else {
            USER_FEED_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    if postId != self.currentKey {
                        self.fetchPost(withPostId: postId)
                    }
                })
                self.currentKey = first.key
            })
        }
    }
    func fetchPost(withPostId postId: String) {
        Database.fetchPost(with: postId) { (post) in
            self.posts.append(post)
            
            self.posts.sort(by: { (post1, post2) -> Bool in
                return post1.creationDate > post2.creationDate
            })
            self.collectionView?.reloadData()
        }
    }


}
