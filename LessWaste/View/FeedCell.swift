//
//  FeedCell.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 26/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

class FeedCell: UICollectionViewCell {
    var delegate: FeedCellDelegate?
    var stackView: UIStackView!
    var post: Post? {
        didSet {
            guard let ownerUid = post?.ownerUid else { return }
            guard let imageUrl = post?.imageUrl else { return }
            guard let likes = post?.likes else { return }
            
            Database.fetchUser(with: ownerUid) { (user) in
                self.profileImageView.loadImage(with: user.profileImageUrl)
                self.usernameButton.setTitle(user.username, for: .normal)
            }
            postImageView.loadImage(with: imageUrl)
            configureLikeButton()
            likesLabel.text = "\(likes) Me gusta"
            postTimeLabel.text = post?.creationDate.timeAgoToDisplay()
        }
    }

    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    lazy var usernameButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("username", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleUsernameTapped), for: .touchUpInside)
        return button
    }()
    lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleOptionsTapped), for: .touchUpInside)
        return button
    }()
    lazy var  postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapToLike))
        likeTap.numberOfTapsRequired = 2
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(likeTap)
        return iv
    }()
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .red
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
     
        return button
    }()
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "text.bubble"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    lazy var ingridientsButton: UIButton = {
           let button = UIButton(type: .system)
           button.setImage(UIImage(systemName: "list.bullet.below.rectangle"), for: .normal)
           button.tintColor = .black
           button.addTarget(self, action: #selector(handleShowDetail), for: .touchUpInside)
           return button
       }()
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = .black
        return button
        
    }()
    lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "3 Me gusta"
        //agregar touch listener
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes))
        likeTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(likeTap)
        
        return label
    }()
    lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "bla bla bla"
        
        return label
    }()
    lazy var postTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.text = "2 DAYS AGO"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //creador de la vista
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40/2
        addSubview(usernameButton)
        usernameButton.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        addSubview(optionsButton)
        optionsButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        optionsButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        configureActionsButtons()
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func configureActionsButtons() {
        stackView = UIStackView(arrangedSubviews: [
            likeButton,
            commentButton,
            ingridientsButton
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight:0, width: 120, height: 50)
        addSubview(saveButton)
        saveButton.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 50)
        addSubview(likesLabel)
        likesLabel.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    // MARK: Configuradores
    //Actualizado a protocolo para mantener el MVC
    @objc func handleUsernameTapped() {
        delegate?.handleUsernameTapped(for: self)
    }
    
    @objc func handleOptionsTapped() {
        delegate?.handleOptionsTapped(for: self)
    }
    
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(for: self, isDoubleTap: false)
    }
    
    @objc func handleCommentTapped() {
        delegate?.handleCommentTapped(for: self)
    }
    
    @objc func handleShowLikes() {
        delegate?.handleShowLikes(for: self)
    }
    
    @objc func handleDoubleTapToLike() {
        delegate?.handleLikeTapped(for: self, isDoubleTap: true)
    }
    @objc func handleShowDetail() {
        delegate?.handleDetailTapped(for: self)
    }
    
    func configureLikeButton() {
        delegate?.handleConfigureLikeButton(for: self)
    }
    
    func configureCommentIndicatorView() {
        delegate?.configureCommentIndicatorView(for: self)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
