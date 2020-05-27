//
//  RecetasViewController.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 11/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase

class RecetasViewController: UIViewController{
    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()
    var recetas: [Receta] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        title = K.appName
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()

        // Do any additional setup after loading the view.
    }
    func loadMessages() {
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.recetaTitle)
            .addSnapshotListener { (querySnapshot, error) in
            if let e = error {
               let alert = UIAlertController(title: "Something happened", message: e.localizedDescription.description, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let recipeCreator = data[K.FStore.senderField] as? String, let recipeBody = data[K.FStore.bodyField] as? String, let recipeTitle = data[K.FStore.recetaTitle] as? String {
                            let newRecipe = Receta(sender: recipeCreator, body: recipeBody, title: recipeTitle)
                            print(data)
                            self.recetas.append(newRecipe)
                        }
                    }
                }
            }
        }
    }
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}


extension RecetasViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recetas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! RecetaCell
        cell.titleReceta.text = recetas[indexPath.row].title
        
        return cell
    }
    
}
