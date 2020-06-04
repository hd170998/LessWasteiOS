//
//  LoginVC.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 14/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    let logoContainerView: UIView = {
        let view = UIView()
        let logoImageVIew = UIImageView(image: #imageLiteral(resourceName: "logo_white"))
        logoImageVIew.contentMode = .scaleAspectFill
        view.addSubview(logoImageVIew)
        logoImageVIew.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageVIew.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageVIew.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .none
        return tf
    }()
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        return tf
    }()
    let logInButton: UIButton={
        let button  = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "¿No tienes cuenta? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Registarte",attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSingUp), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {

        super.viewDidLoad()
        view.backgroundColor = .white
        //hide Nav Bar
        navigationController?.navigationBar.isHidden = true
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        confugureViewComponents()
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
    }
    @objc func handleShowSingUp(){
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
        
    }
    @objc func handleLogin(){
        guard
        let email = emailTextField.text,
        let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let e = error{
                let alert = UIAlertController(title: "Something happened", message: e.localizedDescription.description, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else { return }
            
            mainTabVC.confugureViewControllers()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func confugureViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, logInButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
    }
    
    @objc func formValidation() {
        
        // ensures that email and password text fields have text
        guard
            emailTextField.hasText,
            passwordTextField.hasText else {
                
                // handle case for above conditions not met
                logInButton.isEnabled = false
                logInButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
                return
        }
        
        // handle case for conditions were met
        logInButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        logInButton.isEnabled = true
        
    }

}
