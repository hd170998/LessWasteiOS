//
//  UploadPostViewController.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 15/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase

class UploadPostViewController: UIViewController, UITextViewDelegate {
    
    enum UploadAction: Int {
           case UploadPost
           case SaveChanges
           
           init(index: Int) {
               switch index {
               case 0: self = .UploadPost
               case 1: self = .SaveChanges
               default: self = .UploadPost
               }
        }
        
    }
    var uploadAction: UploadAction!
    var selectedImage: UIImage?
    var postToEdit: Post?
    
    let captionField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nombre tu creacion"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .sentences
        return tf
    }()
    
    let ytField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Inserta algun video de tu preparacion"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    let descriptionTextView: UITextView = {
       let tv = UITextView()
        tv.backgroundColor = .lightGray
        tv.font = UIFont.systemFont(ofSize: 12)
        return tv
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.setTitle("Compartir", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleUploadAction), for: .touchUpInside)
        return button
    }()
    // MARK: - UITextView
    func textViewDidChange(_ textView: UITextView) {
        guard !textView.text.isEmpty else {
            actionButton.isEnabled = false
            actionButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        actionButton.isEnabled = true
        actionButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViewController(forUploadAction: uploadAction)
    }
    
    // MARK: VIewConfig
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureComponents()
        loadImage()
        descriptionTextView.delegate = self
    }
    func configureComponents() {
        view.backgroundColor = .white
        
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        view.addSubview(captionField)
        captionField.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 46)
        view.addSubview(ytField)
        ytField.anchor(top: captionField.bottomAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 46)
        view.addSubview(descriptionTextView)
        descriptionTextView.anchor(top: ytField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
        view.addSubview(actionButton)
        actionButton.anchor(top: descriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 40)
    }
    // MARK: Configuradores
    @objc func handleUploadAction() {
        buttonSelector(uploadAction: uploadAction)
    }
    
    func buttonSelector(uploadAction: UploadAction) {
        switch uploadAction {
            case .UploadPost:
                handleUploadPost()
            case .SaveChanges:
                handleSavePostChanges()
        }
    }
    func configureViewController(forUploadAction uploadAction: UploadAction) {
        if uploadAction == .SaveChanges {
            guard let post = self.postToEdit else { return }
            actionButton.setTitle("Guardar Cambios", for: .normal)
            self.navigationItem.title = "Editar Receta"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(handleCancel))
            navigationController?.navigationBar.tintColor = .black
            photoImageView.loadImage(with: post.imageUrl)
            descriptionTextView.text = post.description
            captionField.text = post.caption
            ytField.text = post.link
            
        } else {
            actionButton.setTitle("Compartir", for: .normal)
            self.navigationItem.title = "Subir receta"
        }
    }
    func loadImage() {
        guard let selectedImage = self.selectedImage else { return }
        photoImageView.image = selectedImage
    }
    // MARK: Handlers
    func handleSavePostChanges() {
        guard let post = self.postToEdit else { return }
        guard let updatedCaption = captionField.text else { return }
        guard let updateDescription = descriptionTextView.text else {return}
        guard let updateLink = ytField.text else {return}
        
        
        if updateDescription.contains("#") {
            self.uploadHashtagToServer(withPostId: post.postId)
        }
        
        POSTS_REF.child(post.postId).child("caption").setValue(updatedCaption) { (err, ref) in
            POSTS_REF.child(post.postId).child("descripcion").setValue(updateDescription){(err, ref) in
                POSTS_REF.child(post.postId).child("link").setValue(updateLink){(err, ref) in
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        }
    }
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleUploadPost() {
        guard
            let caption = captionField.text,
            let postImg = photoImageView.image,
            let currentUid = Auth.auth().currentUser?.uid,
            let ytLink = ytField.text,
            let description = descriptionTextView.text
            
        else { return }
        guard let uploadData = postImg.jpegData(compressionQuality: 0.5) else {return}
        let creationData = Int(NSDate().timeIntervalSince1970)
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_POST_IMAGES_REF.child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("super fail", error.localizedDescription.description)
                return
            }
            storageRef.downloadURL { (url, error) in
                guard let imageURL = url?.absoluteString else {return}
                let values = [
                    "caption":caption,
                    "creationDate":creationData,
                    "likes": 0,
                    "imageUrl":imageURL,
                    "ownerUid": currentUid,
                    "link":ytLink,
                    "descripcion":description
                ] as [String: Any]
                
                let postID = POSTS_REF.childByAutoId()
                guard let postKey = postID.key else {return}
                
                postID.updateChildValues(values) { (error, ref) in
                    // update user-post structure
                    let userPostsRef = USER_POSTS_REF.child(currentUid)
                    userPostsRef.updateChildValues([postKey: 1])
                    // update user-feed structure
                    self.updateUserFeeds(with: postKey)
                    
                    // upload hashtag to server
                    if description.contains("#") {
                        self.uploadHashtagToServer(withPostId: postKey)
                    }
                    
                    self.dismiss(animated: true, completion: {
                        self.tabBarController?.selectedIndex = 0
                    })
                }
            }
        }
    }
    func updateUserFeeds(with postId: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let values = [postId: 1]
        
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(values)
        }
        
        USER_FEED_REF.child(currentUid).updateChildValues(values)
    }
    func uploadHashtagToServer(withPostId postId: String) {
        guard let caption = descriptionTextView.text else{return}
        let words: [String] = caption.components(separatedBy: .whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let hashtagValues = [postId: 1]
                HASHTAG_POST_REF.child(word.lowercased()).updateChildValues(hashtagValues)
            }
        }
    }
}
