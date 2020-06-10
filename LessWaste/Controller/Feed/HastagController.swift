//
//  HastagController.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 10/06/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "HashtagCell"

class HastagController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: - Properites
    var posts = [Post]()
    var hashtag: String?

    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        collectionView?.backgroundColor = .white
        self.collectionView!.register(HashtagCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        fetchPosts()
    }

    
    // MARK: UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let width = (view.frame.width - 2) / 3
           return CGSize(width: width, height: width)
       }
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HashtagCell
        // Configure the cell
        cell.post = posts[indexPath.item]
    
        return cell
    }
    func configureNavigationBar() {
        guard let hashtag = self.hashtag else { return }
        navigationItem.title = hashtag
        
    }
    
    func fetchPosts() {
        guard let hashtag = self.hashtag else { return }
        
        HASHTAG_POST_REF.child(hashtag).observe(.childAdded) { (snapshot) in
            
            let postId = snapshot.key
            
            Database.fetchPost(with: postId, completion: { (post) in
                self.posts.append(post)
                self.collectionView?.reloadData()
            })
        }
    }

}
