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

class SearchVC: UITableViewController {
    // MARK: - Properties
     var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        configurateNavController()
        fetchUsers()
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
        return users.count
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
        cell.user = users[indexPath.row]
        return cell
    }
    // MARK: - Handlers
    func configurateNavController() {
        navigationItem.title = "Explore"
    }
    
    func fetchUsers() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else{return}
            
            let user = User(uid: uid, dictionary: dictionary)
            self.users.append(user)
            self.tableView.reloadData()
        }
    }

}

