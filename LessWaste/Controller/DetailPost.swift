//
//  DetailPost.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 03/06/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import YouTubeVideoPlayer

class DetailPost: UIViewController {
    // MARK: - Properties
    var youtubeLink = ""
    var post: Post?{
        didSet{
            guard let caption = post?.caption else{return}
            guard let description = post?.description else {return}
            guard let ingridients = post?.ingridients else {return}
            guard let ytLink = post?.link else {return}
            guard let imageUrl = post?.imageUrl else { return }
            
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
    lazy var descriptionLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.text = "Cargando"
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
        
        postImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 300)
        view.addSubview(titleLabel)
        
        titleLabel.anchor(top: postImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
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
}
