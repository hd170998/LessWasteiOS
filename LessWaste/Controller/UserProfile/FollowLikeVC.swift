//
//  FollowLikeVC.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 20/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase
private let reuseIdentifier = "FollowCell"
class FollowLikeVC: UITableViewController, FollowCellDelegate{
    // MARK: - Properties
    var followCurrentKey: String?
    var likeCurrentKey: String?
    
    enum ViewingMode: Int {
        
        case Following
        case Followers
        case Likes
        
        init(index: Int) {
            switch index {
            case 0: self = .Following
            case 1: self = .Followers
            case 2: self = .Likes
            default: self = .Following
            }
        }
    }
    var viewingMode: ViewingMode!
    var uid: String?
    var users = [User]()
    var postId: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifier)
        configureNavigationTitle()
        
        // fetch users
        fetchUsers()
        
        // clear separator lines
        tableView.separatorColor = .clear
    
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowLikeCell
        
        cell.delegate = self
                
        cell.user = users[indexPath.row]
        
        return cell
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if users.count > 3 {
            if indexPath.item == users.count - 1 {
                fetchUsers()
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    // MARK: - Configuradores
    
    func configureNavigationTitle() {
        guard let viewingMode = self.viewingMode else { return }
        
        switch viewingMode {
        case .Followers: navigationItem.title = "Seguidores"
        case .Following: navigationItem.title = "Siguiendo"
        case .Likes: navigationItem.title = "Me gusta"
        }
    }
    // MARK: - API
    
    func getDatabaseReference() -> DatabaseReference? {
        guard let viewingMode = self.viewingMode else { return nil }
        
        switch viewingMode {
        case .Followers: return USER_FOLLOWER_REF
        case .Following: return USER_FOLLOWING_REF
        case .Likes: return POST_LIKES_REF
        }
    }
    // MARK: - FollowCellDelegate Protocol
    
    func handleFollowTapped(for cell: FollowLikeCell) {
        
        guard let user = cell.user else { return }
        
        if user.isFollowed {
            
            user.unfollow()
            
            // configure follow button for non followed user
            cell.followButton.setTitle("Seguir", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            
        } else {
            
            user.follow()
            
            // configure follow button for followed user
            cell.followButton.setTitle("Siguiendo", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.backgroundColor = .white
        }
    }
    
    func fetchUser(withUid uid: String) {
        Database.fetchUser(with: uid, completion: { (user) in
            self.users.append(user)
            self.tableView.reloadData()
        })
    }
    
    func fetchUsers() {
        guard let ref = getDatabaseReference() else { return }
        guard let viewingMode = self.viewingMode else { return }
        
        switch viewingMode {
            
        case .Followers, .Following:
            guard let uid = self.uid else { return }
            
            if followCurrentKey == nil {
                ref.child(uid).queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    allObjects.forEach({ (snapshot) in
                        let followUid = snapshot.key
                        self.fetchUser(withUid: followUid)
                    })
                    self.followCurrentKey = first.key
                })
            }
        case .Likes:
            guard let postId = self.postId else { return }
            
            if likeCurrentKey == nil {
                ref.child(postId).queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    allObjects.forEach({ (snapshot) in
                        let likeUid = snapshot.key
                        self.fetchUser(withUid: likeUid)
                    })
                    self.likeCurrentKey = first.key
                })
                
            } else {
                ref.child(postId).queryOrderedByKey().queryEnding(atValue: self.likeCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    allObjects.forEach({ (snapshot) in
                        let likeUid = snapshot.key
                        
                        if likeUid != self.likeCurrentKey {
                            self.fetchUser(withUid: likeUid)
                        }
                    })
                    self.likeCurrentKey = first.key
                })
            }
        }
    }
}
