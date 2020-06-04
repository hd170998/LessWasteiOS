//
//  CommentCell.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 02/06/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import ActiveLabel

class CommentCell: UICollectionViewCell {
    var comment: Comment? {
        
        didSet {
            
            guard let user = comment?.user else { return }
            guard let profileImageUrl = user.profileImageUrl else { return }
            
            profileImageView.loadImage(with: profileImageUrl)
            
            configureCommentLabel()
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let commentLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48/2
        addSubview(commentLabel)
        commentLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        commentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    // MARK: - Configuradores
    
    func configureCommentLabel() {
        guard let comment = self.comment else { return }
        guard let user = comment.user else { return }
        guard let username = user.username else { return }
        guard let commentText = comment.commentText else { return }
        guard let date = getCommentTimeStamp() else {return}
        
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        commentLabel.enabledTypes = [.hashtag, .mention, .url, customType]
        
        commentLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            
            switch type {
            case .custom:
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            default: ()
            }
            return atts
        }
        
        commentLabel.customize { (label) in
            label.text = "\(username) \(commentText) \(date)"
            label.customColor[customType] = .black
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            label.numberOfLines = 0
        }
        
    }
    func getCommentTimeStamp() -> String? {
        
        guard let comment = self.comment else { return nil }
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        let now = Date()
        return dateFormatter.string(from: comment.creationDate, to: now)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
