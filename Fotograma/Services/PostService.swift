//
//  PostService.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/18/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PostService {
  static func create(for image: UIImage) {
    let imageRef = Storage.storage().reference().child("test_image.jpg")
    
    StorageService.uploadImage(image, at: imageRef, completion: { downloadURL in
      guard let downloadURL = downloadURL else { return }
      
      let urlString = downloadURL.absoluteURL
      print("Image URL: \(urlString)")
    })
  }
}
