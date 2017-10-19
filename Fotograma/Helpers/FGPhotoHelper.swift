//
//  FGPhotoHelper.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/18/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import UIKit

class FGPhotoHelper: NSObject {

  // MARK: - Properties
  
  // Completion handler will be called when user has selected an image from UIImagePickerController
  var completionHandler: ((UIImage) -> Void)?

  // MARK: - Helper Methods
  
  // Presents action sheet from a ViewController
  func presentActionSheet(from viewController: UIViewController) {
    // Create alert controller with ActionSheet style
    let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .actionSheet)
    
    // If camera is available on device
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      // Create action for taking a photograph
      let capturePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { [unowned self] action in
        // Present ImagePickerController
        self.presentImagePickerController(with: .camera, from: viewController)
      })
      
      // Add action to sheet
      alertController.addAction(capturePhotoAction)
    }
    
    // If photo library is available on device
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      let uploadAction = UIAlertAction(title: "Upload from Library", style: .default, handler: { [unowned self] action in
        // Present ImagePickerController
        self.presentImagePickerController(with: .photoLibrary, from: viewController)
      })
      
      // Add action to sheet
      alertController.addAction(uploadAction)
    }
    
    // Create action for cancelling
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    // Add cancel action to sheet
    alertController.addAction(cancelAction)
    
    // Present action sheet
    viewController.present(alertController, animated: true)
  }

  // Present ImagePickerController from a ViewController
  func presentImagePickerController(with sourceType: UIImagePickerControllerSourceType, from viewController: UIViewController) {
    // Create new instance of ImagePickerController
    let imagePickerController = UIImagePickerController()
    // Set the source type
    imagePickerController.sourceType = sourceType
    // Set this as delegate
    imagePickerController.delegate = self
    // Present view
    viewController.present(imagePickerController, animated: true)
  }
}

extension FGPhotoHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    // Select image
    if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      // Call the completion handler and send in the selected image
      completionHandler?(selectedImage)
    }
    
    // Dismiss picker
    picker.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    // Dismiss picker
    picker.dismiss(animated: true, completion: nil)
  }
}
