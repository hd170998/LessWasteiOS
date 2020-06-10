//
//  SearchVC.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 15/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SearchUserCell"

class SearchVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    var users = [User]()
    var filteredUsers = [User]()
    var searchBar = UISearchBar()
    var inSearchMode = false
    var collectionView: UICollectionView!
    var collectionViewEnabled = true
    var posts = [Post]()
    var currentKey: String?
    var userCurrentKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .none
        
        configureSearchBar()
        configureRefreshControl()
        configureCollectionView()
        fetchUsers()
        fetchPosts()
    }
    // MARK: - UISearchBar
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        collectionView.isHidden = true
        collectionViewEnabled = false
        tableView.separatorColor = .lightGray
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //funcion para buscar cuando cambia el texto
        let searchText = searchText.lowercased()
        if searchText.isEmpty || searchText == " "{
            inSearchMode = false
            tableView.reloadData()
        }else{
            inSearchMode = true
            filteredUsers = users.filter({ (user) -> Bool in
                return user.username.contains(searchText)
            })
            tableView.reloadData()
        }
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        inSearchMode = false
        searchBar.text = nil
        collectionViewEnabled = true
        collectionView.isHidden = false
        tableView.separatorColor = .clear
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if inSearchMode{
            return filteredUsers.count
        }else{
            return users.count
        }
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        // create instance of user profile vc
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        // passes user from searchVC to userProfileVC
        userProfileVC.user = user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        var user : User!
        if inSearchMode{
            user = filteredUsers[indexPath.row]
        }else{
            user = users[indexPath.row]
        }
        cell.user = user
        return cell
    }
    // MARK: - UICollectionView
    func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - (tabBarController?.tabBar.frame.height)! - (navigationController?.navigationBar.frame.height)!)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: "SearchPostCell")
        
        
        tableView.addSubview(collectionView)
        tableView.separatorColor = .clear
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2)/3
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 20 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchPostCell", for: indexPath) as! SearchPostCell
        cell.post = posts[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedController = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedController.viewSinglePost = true
        feedController.post = posts[indexPath.row]
        navigationController?.pushViewController(feedController, animated: true)
    }
    // MARK: - Configuracion
    func configureSearchBar() {
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        searchBar.tintColor = .black
    }
    @objc func handleRefresh() {
           posts.removeAll(keepingCapacity: false)
           self.currentKey = nil
           fetchPosts()
           collectionView?.reloadData()
       }
       
       func configureRefreshControl() {
           let refreshControl = UIRefreshControl()
           refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
           self.tableView.refreshControl = refreshControl
       }
    
    func fetchUsers() {
        
        if userCurrentKey == nil {
            USER_REF.queryLimited(toLast: 10).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let uid = snapshot.key
                    
                    Database.fetchUser(with: uid, completion: { (user) in
                        self.users.append(user)
                        self.tableView.reloadData()
                    })
                })
                self.userCurrentKey = first.key
            }
        } else {
            USER_REF.queryOrderedByKey().queryEnding(atValue: userCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                allObjects.removeAll(where: { $0.key == self.userCurrentKey })
                
                allObjects.forEach({ (snapshot) in
                    let uid = snapshot.key

                    if uid != self.userCurrentKey {
                        Database.fetchUser(with: uid, completion: { (user) in
                            self.users.append(user)
                            if self.users.count == allObjects.count  {
                                self.tableView.reloadData()
                            }
                        })
                    }
                })
                self.userCurrentKey = first.key
            })
        }
    }
    func fetchPosts() {
        if currentKey == nil {
            
            // inital data pull
            POSTS_REF.queryLimited(toLast: 21).observeSingleEvent(of: .value, with: { (snapshot) in
                self.tableView.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    
                    Database.fetchPost(with: postId, completion: { (post) in
                        self.posts.append(post)
                        self.collectionView.reloadData()
                    })
                })
                self.currentKey = first.key
            })
        } else {
            
            // paginate here
            POSTS_REF.queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    
                    if postId != self.currentKey {
                        Database.fetchPost(with: postId, completion: { (post) in
                            self.posts.append(post)
                            self.collectionView.reloadData()
                        })
                    }
                })
                self.currentKey = first.key
            })
        }
    }

}

