//
//  StorageService.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/18/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import UIKit
import FirebaseStorage

struct StorageService {
  // Method for uploading images
  static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
    // Make sure we can get image data from image as JPEG
    guard let imageData = UIImageJPEGRepresentation(image, 0.1) else { return completion(nil) }
    
    // Upload image to Firebase Storage
    reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
      // If error
      if let error = error {
        // Show error message
        assertionFailure(error.localizedDescription)
        return completion(nil)
      }
      
      // Otherwise complete and send image URL
      completion(metadata?.downloadURL())
    })
  }
}
