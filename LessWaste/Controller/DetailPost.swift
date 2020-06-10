//
//  DetailPost.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 03/06/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import YouTubeVideoPlayer
import ActiveLabel
import Firebase

class DetailPost: UIViewController {
    // MARK: - Properties
    var youtubeLink = ""
    var post: Post?{
        didSet{
            guard let caption = post?.caption else{return}
            guard let ownerUid = post?.ownerUid else { return }
            guard let description = post?.description else {return}
            guard let ytLink = post?.link else {return}
            guard let imageUrl = post?.imageUrl else { return }
            Database.fetchUser(with: ownerUid) { (user) in
                self.configurePostCaption(user: user)
            }
            
            postImageView.loadImage(with: imageUrl)
            titleLabel.text = caption
            descriptionLabel.text = description
            youtubeLink = ytLink
            
            
        }
    }
    let postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.text = "Cargando"
        return label
        
    }()
    lazy var descriptionLabel : ActiveLabel = {
        let label = ActiveLabel()
        label.numberOfLines = 0
        
        return label
    }()
    let videoContainerView: UIView = {
        let view = UIView()
        return view
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        view.addSubview(postImageView)
        
        postImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 250)
        view.addSubview(titleLabel)
        
        titleLabel.anchor(top: postImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 5, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 300)
        view.addSubview(videoContainerView)
        videoContainerView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 50, paddingRight: 0, width: 0, height: 200)
        let player : YouTubeVideoPlayer = .shared
        player.isHidden = true
        videoContainerView.addSubview(player)
        player.play(videoId: handleLiga(), sourceView: videoContainerView)
        
    }
    func handleLiga() -> String {
        let code = youtubeLink.split(separator: "/")
        return String(code.last!)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.backgroundColor = .lightGray
        
        
    }
    func configurePostCaption(user: User) {
        guard let post = self.post else { return }
        guard let caption = post.description else { return }
        
        
        // enable username as custom type
        descriptionLabel.enabledTypes = [.mention, .hashtag, .url]
        
        // configure usnerame link attributes
        descriptionLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            
            switch type {
            case .custom:
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            default: ()
            }
            return atts
        }
        
        descriptionLabel.customize { (label) in
            label.text = "\(caption)"
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            label.handleHashtagTap { (hashtag) in
                let hashtagController = HastagController(collectionViewLayout: UICollectionViewFlowLayout())
                hashtagController.hashtag = hashtag.lowercased()
                
                self.navigationController?.pushViewController(hashtagController, animated: true)
            }
            descriptionLabel.numberOfLines = 0
        }
    }
}
