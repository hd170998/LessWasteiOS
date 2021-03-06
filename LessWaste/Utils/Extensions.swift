//
//  Extensions.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 14/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase
extension UIView{
    func anchor(top : NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top{
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left{
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom{
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right{
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if width != 0{
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0{
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension UIButton {
    
    func configure(didFollow: Bool) {
        
        if didFollow {
            
            
            self.setTitle("Siguiendo", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.backgroundColor = .white
            
        } else {
            
            // cambia el boton de la tabla
            self.setTitle("Seguir", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0
            self.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
    }
}
extension Database{
    static func fetchUser(with uid: String, completion: @escaping(User) -> ()) {
           
           USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
               guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
               let user = User(uid: uid, dictionary: dictionary)
               completion(user)
           }
       }
    static func fetchPost(with postId: String, completion: @escaping(Post) -> ()) {
        
        POSTS_REF.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let ownerUid = dictionary["ownerUid"] as? String else { return }
            
            Database.fetchUser(with: ownerUid, completion: { (user) in
                let post = Post(postId: postId, user: user, dictionary: dictionary)
                completion(post)
            })
        }
    }
}
extension Date {
    
    func timeAgoToDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "Segundos"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "Min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "Horas"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "Dias"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "sem"
        } else {
            quotient = secondsAgo / month
            unit = "meses"
        }
        return "Hace \(quotient) \(unit)\(quotient == 1 ? "" : "")"
    }
}
