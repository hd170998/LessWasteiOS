//
//  MainTabVC.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 15/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        confugureViewControllers()
        checkIfUserIsLoggedIn()
        
    }
    func confugureViewControllers() {
        let feedVC = configureNavParameters(unselectedimage: UIImage(systemName: "house")!, selectedImage: UIImage(systemName: "house.fill")!, rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        let searchVC = configureNavParameters(unselectedimage: UIImage(systemName: "magnifyingglass.circle")!, selectedImage: UIImage(systemName: "magnifyingglass.circle.fill")!, rootViewController: SearchVC())
        let selectImageVC = configureNavParameters(unselectedimage: UIImage(systemName: "plus.square")!, selectedImage: UIImage(systemName: "plus.square.fill")!)
        let notificationVC = configureNavParameters(unselectedimage: UIImage(systemName: "heart")!, selectedImage: UIImage(systemName: "heart.fill")!, rootViewController: NotificationsVC())
        let userProfileVC = configureNavParameters(unselectedimage: UIImage(systemName: "person.circle")!, selectedImage: UIImage(systemName: "person.circle.fill")!, rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        viewControllers = [feedVC,searchVC,selectImageVC,notificationVC,userProfileVC]
        tabBar.tintColor = .black
        
    }
    
    //Navegacion
    func configureNavParameters(unselectedimage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedimage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        
        return navController
    }
    // MARK: - TabBar
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2{
            let selectimageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navcontroller = UINavigationController(rootViewController: selectimageVC)
            navcontroller.navigationBar.tintColor = .black
            present(navcontroller, animated: true, completion: nil)
            return false
        }
        return true
    }
    // MARK: - API
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil{
            DispatchQueue.main.async {
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                
                navController.modalPresentationStyle = .fullScreen
                
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
    }
}
