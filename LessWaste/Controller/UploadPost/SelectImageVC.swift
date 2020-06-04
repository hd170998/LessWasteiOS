//
//  SelectImageVC.swift
//  LessWaste
//
//  Created by Héctor David Hernández Rodríguez on 20/05/20.
//  Copyright © 2020 Héctor David Hernández Rodríguez. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "SelectPhotoCell"
private let headerIdentifier = "SelectPhotoHeader"

class SelectImageVC: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage: UIImage?
    var header: SelectPhotoHeader?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        collectionView?.register(SelectPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
         collectionView?.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)

        // Do any additional setup after loading the view.
        collectionView?.backgroundColor = .white
        
        configureNavigationButtons()
        fetchPhotos()
    }
    // MARK: UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3)/4
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectPhotoCell
    
        // Configure the cell
        cell.photoImageView.image = images[indexPath.row]
    
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.row]
        self.collectionView?.reloadData()
        let indexPath = IndexPath(item: 0, section: 0)
               collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectPhotoHeader
        self.header = header
        
        if let selectedImage = self.selectedImage{
            header.photoImageView.image = selectedImage
            
            if let index = images.firstIndex(of: selectedImage){
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { (image, info) in
                    header.photoImageView.image = image
                })
            }
        }
        
        return header
    }

    // MARK: Configuradores
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNext() {
        let uploadPostVC = UploadPostViewController()
        uploadPostVC.selectedImage = self.header?.photoImageView.image
        navigationController?.pushViewController(uploadPostVC, animated: true)
        
    }
    func configureNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    func getAssetFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        //limite de ftos
        options.fetchLimit = 30
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        
        return options
    }
    func fetchPhotos() {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
        //obtener las imagenes
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                //solicitar representacion de imagenes
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    if let image = image{
                        //agregar imagen a la fuente de informacion
                        self.images.append(image)
                        self.assets.append(asset)
                        // selecciona una foto como la primera imagen
                        if self.selectedImage == nil{
                            self.selectedImage = image
                        }
                        //vuelve a cargar la colleccion
                        if count == allPhotos.count - 1 {
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
}
