//
//  PhotoVaultVC.swift
//  DualWhatsApp
//
//  Created by Nexios Technologies on 13/10/25.
//

import UIKit
import CoreData
import PhotosUI

class PhotoVaultVC: UIViewController {

    // MARK: - OUTLET
    @IBOutlet weak var photoCV: UICollectionView!
    
    // MARK: - PROPERTY
    var photos: [PhotoEntity] = []
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photo Vault"
        setupUI()
        fetchPhotos()
        photoCV.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - UI SETUP
    func setupUI(){
        photoCV.register( UINib(nibName: WallpaperCVCell.identifier, bundle: nil), forCellWithReuseIdentifier: WallpaperCVCell.identifier)
    }
    
    //MARK: - SOCKET EVENT
    
    // MARK: - BUTTON CLICK
    @IBAction func addPhotoClick(_ sender: UIButton) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0 // 0 = unlimited selection
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - OTHER
    func fetchPhotos() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
        do {
            photos = try context.fetch(fetchRequest)
            photoCV.reloadData()
        } catch {
            print("Failed to fetch photos:", error)
        }
    }

    func savePhoto(_ image: UIImage) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let entity = PhotoEntity(context: context)
        entity.imageData = image.jpegData(compressionQuality: 0.9)
        do {
            try context.save()
            photos.append(entity)
            photoCV.reloadData()
        } catch {
            print("Failed to save photo:", error)
        }
    }
    
    // MARK: - API CALLING
    
    // MARK: - DELEGATE

}
extension PhotoVaultVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WallpaperCVCell.identifier, for: indexPath as IndexPath) as! WallpaperCVCell
        if let data = photos[indexPath.item].imageData, let img = UIImage(data: data) {
            cell.ivImage.image = img
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 30)/2
        return CGSize(width: width, height: width * 1.3)
    }
}
// MARK: - PHPickerViewControllerDelegate
extension PhotoVaultVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    guard let self = self else { return }
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.savePhoto(image)
                        }
                    }
                }
            }
        }
    }
}
