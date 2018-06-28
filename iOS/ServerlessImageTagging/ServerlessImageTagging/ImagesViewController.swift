//
//  ViewController.swift
//  ServerlessImageTagging
//
//  Created by Joe Anthony Peter Amanse on 6/25/18.
//  Copyright © 2018 Joe Anthony Peter Amanse. All rights reserved.
//

import UIKit

class ImagesViewController: UICollectionViewController {
    
    fileprivate let reuseIdentifier = "imageCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 2
    let picker = UIImagePickerController()
    var refreshControl: UIRefreshControl?
    let cloudant = SwiftCloudantHelper(cloudantURL: "https://d1dda683-a71d-43ca-9c92-bf111700dc00-bluemix.cloudant.com", username: "d1dda683-a71d-43ca-9c92-bf111700dc00-bluemix", password: "fa2971ea3c351e710593bd1fb85d6b714dd5d2c9cdc03a49568f58fd8874cb1f", dbName: "newimages", dbNameProcessed: "processed")
    
    var imagesTaken: [UIImage] = []
    var images: [ImageUploaded] = []

    let searchController = UISearchController(searchResultsController: nil)

    @IBAction func addImageFromGallery(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    @IBAction func captureImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
        } else {
            print("Camera not available")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Image Picker delegate
        picker.delegate = self
        
        // Add refresh controller
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView?.refreshControl = refreshControl
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh() {
        collectionView?.reloadData()
        self.refreshControl?.endRefreshing()
    }


}


extension ImagesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // save to iPhone's photos
        // UIImageWriteToSavedPhotosAlbum(info[UIImagePickerControllerOriginalImage] as! UIImage, nil, nil, nil)
        
        // store in mem
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagesTaken.append(image)
//        print("png size: " + Data(UIImagePNGRepresentation(image)!).description)
//        print("jpeg size " + Data(UIImageJPEGRepresentation(image, 0.025)!).description)
//        print(info)
        var newImageUploaded = ImageUploaded(id: nil, image: UIImageJPEGRepresentation(image, 1.0), tags: nil)
        
        cloudant.saveDocument(image, name: "testAttachment") { response in
            print("done saving")
            print(response)
            newImageUploaded?.id = response["id"] as! String
            self.images.append(newImageUploaded!)
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
        
//        collectionView?.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ImagesViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
    }
}

// Data Source
extension ImagesViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! ImageCustomCell
        
        cell.imageView.image = UIImage(data: images[indexPath.row].image!)
        cell.tagsLabel.text = ""
        
        // DEBUG...
        // remove this after
        // place outside of collectionView
        self.cloudant.getTags(images[indexPath.row].id!) { response in
            do {
                let json = try JSONSerialization.data(withJSONObject: response, options: [])
                var tags = try JSONDecoder().decode([Tag].self, from: json)
                var thisImage = self.images.first(where: {
                    $0.id == self.images[indexPath.row].id
                })
                thisImage?.tags = tags
                tags = tags.sorted(by: { tag, tag2 in tag.score > tag2.score})
                
                DispatchQueue.main.async {
                    cell.tagsLabel.text = tags.map({ $0.tag }).joined(separator: ", ")
                }
            } catch {
                
            }
        }
        return cell
    }
}

// DelegateFlowLayout
extension ImagesViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
