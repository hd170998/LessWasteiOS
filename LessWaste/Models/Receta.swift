//
//  Receta.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 12/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase
struct Receta {
    let sender: String
    let body: String
    let title: String
//    let ytLink: String
//    var imageLink : String?
//    var caption : String!
//    private var image: UIImage!
    
//    init(image: UIImage, caption: String, sender: String, title: String, body: String, ytLink: String){
//        self.image = image
//        self.caption = caption
//        self.sender = sender
//        self.title = title
//        self.body = body
//        self.ytLink = ytLink
//    }
//    func save(){
//        let newPostKey = Date().timeIntervalSince1970
//        if let imageData = image.jpegData(compressionQuality: 0.6){
//            let imagesReferences = Storage.storage().reference().child("images")
//            let newImageRef = imagesReferences.child(String(newPostKey.nextUp))
//            newImageRef.putData(imageData)
//            newImageRef.downloadURL { (url, error) in
//                if let e = error{
//                    print(e.localizedDescription.description)
//                }else{
//                    let downloadString = url?.absoluteString
//                }
//            }
//        }
//    }
    
    
}
