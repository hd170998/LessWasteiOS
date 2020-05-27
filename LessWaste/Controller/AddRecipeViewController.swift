//
//  AddRecipeViewController.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 13/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase

class AddRecipeViewController: UIViewController{
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextFIeld: UITextField!
    @IBOutlet weak var videoLink: UITextField!
    var uploadImage: UIImage!
    
    let db = Firestore.firestore()
    var recetas : [Receta] = []
    @IBOutlet weak var imagePicker: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func selectedImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        
        let actionSheet = UIAlertController(title: "Seleccionar", message: "Seleccione uan Fuente", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camara", style: .default, handler: { (UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Galeria", style: .default, handler: { (UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Galeria", style: .default, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        if let recipeName = titleTextField.text , let recipeCreator = Auth.auth().currentUser?.email, let recipeBody = bodyTextFIeld.text, let ytLink = videoLink.text{
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: recipeCreator,
                K.FStore.recetaTitle: recipeName,
                K.FStore.bodyField: recipeBody,
                //K.FStore.ytLink: ytLink
            ])
        }
        navigationController?.popToRootViewController(animated: true)
    }
}
extension AddRecipeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.uploadImage = image
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
