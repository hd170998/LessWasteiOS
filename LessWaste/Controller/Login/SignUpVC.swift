//
//  SignUpVC.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 14/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imageSelected  = false
    let plusPhotoBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelectProfile), for: .touchUpInside)
        return button
        
    }()
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .none
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let fullNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nombre Completo"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .words
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .none
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Registrarse", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Ya tienes una cuenta?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Inicia Sesion", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        //background
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoBtn)
        plusPhotoBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        configureViewComponents()
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else {return}
        imageSelected = true
        plusPhotoBtn.layer.cornerRadius = plusPhotoBtn.frame.width/2
        plusPhotoBtn.layer.masksToBounds = true
        plusPhotoBtn.layer.borderColor = UIColor.black.cgColor
        plusPhotoBtn.layer.borderWidth = 2
        plusPhotoBtn.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    @objc func handleShowLogin() {
        _ = navigationController?.popViewController(animated: true)
    }
    @objc func handleSignUp() {
        guard let email = emailTextField.text else{return}
        guard let password = passwordTextField.text else {return}
        guard let fullName = fullNameTextField.text else{return}
        guard let userName = usernameTextField.text else{return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let e = error{
                let alert = UIAlertController(title: "Something happened", message: e.localizedDescription.description, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            //set profile image
            guard let profileImage = self.plusPhotoBtn.imageView?.image else{return}
            //subimos la foto al Storage
            guard let uploadData = profileImage.jpegData(compressionQuality: 0.3) else{return}
            let filename = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if let e = error{
                    let alert = UIAlertController(title: "Failed to Upload Image", message: e.localizedDescription.description, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                storageRef.downloadURL { (url, error) in
                    guard let profileImageUrl = url?.absoluteString else {
                        print("DEBUG: Profile image url is nil")
                        return
                    }
                    guard let uid = user?.user.uid else { return }
                    let dictionaryValues = [
                        "name": fullName,
                        "username": userName,
                        "profileImageUrl": profileImageUrl]
                    let values = [uid: dictionaryValues]
                    Database.database().reference().child("users").updateChildValues(values,withCompletionBlock: {(error, ref) in
                        guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else { return }
                        // configure view controllers in maintabvc
                        mainTabVC.confugureViewControllers()
                        //mainTabVC.isInitialLoad = true

                        // dismiss login controller
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
    @objc func handleSelectProfile(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        let actionSheet = UIAlertController(title: "Seleccionar", message: "Seleccione uan Fuente", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camara", style: .default, handler: { (UIAlertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Galeria", style: .default, handler: { (UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    @objc func formValidation(){
        guard emailTextField.hasText,
            passwordTextField.hasText,
            fullNameTextField.hasText,
            usernameTextField.hasText,
            imageSelected == true
        else{
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    func configureViewComponents() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, fullNameTextField, usernameTextField, passwordTextField, signUpButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoBtn.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 240)
    }

}
