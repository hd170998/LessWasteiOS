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
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true
    
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
extension RecetasViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recetas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellNibName, for: indexPath) as! RecetaCell
        cell.titleReceta.text = recetas[indexPath.row].title
        return cell
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
